//
//  DataSource.m
//  Blocstagram
//
//  Created by Melissa Boring on 10/12/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"
#import <UICKeyChainStore.h>

@interface DataSource () {
    NSMutableArray *_mediaItems;
}

//this property can only be modified by the DataSource instance
@property (nonatomic, strong) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isLoadingOlderItems;

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

@end


@implementation DataSource


+ (instancetype) sharedInstance
{
    
    //declare function ; creates a single instance of the class
    static dispatch_once_t once;
    
    //static variable to hold our shared instanc
    static id sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    //return our shared instance
    return sharedInstance;
}


- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken)
        {
            [self registerForAccessTokenNotification];
        }
        else
        {
            //read from saved file
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (storedMediaItems.count > 0)
                    {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                        
                        //Re download images with a nil image
                        for (Media* mediaItem in self.mediaItems) {
                            [self downloadImageForMediaItem:mediaItem];
                        }
                        
                       // [self requestNewItemsWithCompletionHandler:nil];
                        
                    }
                    else
                    {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
    }
    
    return self;
}

+ (NSString *) instagramClientID
{
    return @"fd73d6ad200c4e0c8aa13088afdc4b46";
}

//runs after login controller posts the LoginViewControllerDidGetAccessTokenNotification notification
- (void) registerForAccessTokenNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note){
        
        self.accessToken = note.object;
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        // Got a token; populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
        
    }];
}

- (void) deleteMediaItem:(Media *)item
{
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    [mutableArrayWithKVO removeObject:item];
}


#pragma mark - Completion handler methods

//use this method to get newer items. We'll use the MIN_ID parameter from the last checkpoint to let Instagram know we're only interested in items with a higher ID (i.e., newer items). We'll also pass back the error object if it's there.

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    self.thereAreNoMoreOlderMessages = NO;
    
    if (self.isRefreshing == NO)
    {
        self.isRefreshing = YES;
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters;
        
        if (minID)
        {
            parameters = @{@"min_id": minID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error){
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO)
    {
        self.isLoadingOlderItems = YES;
        
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters;
        
        if (maxID)
        {
            parameters = @{@"max_id": maxID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error){
            self.isLoadingOlderItems = NO;
        
            if (completionHandler) {
                completionHandler(error);
            }
        }];

    }
}

//create request and turn response into a dictionary
- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler
{

    // only try to get the data if there's an access token
    if (self.accessToken)
    {
        // do the network request in the background, so the UI doesn't lock up
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters)
            {
                // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url)
            {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                
                //NSData *responseData = NSURLSessio
                
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData)
                {
                    NSError *jsonError;
                    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    
                    if (feedDictionary)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // done networking, go back on the main thread
                            [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                            
                            //send a nil "response" to the completion handler because we successfully connected, parsed JSON and created a feedDictionary
                            if (completionHandler) {
                                completionHandler(nil);
                            }
                            
                        });
                    }
                    //an error occured when creating the feedDictionary, throw a jsonError
                    else if (completionHandler)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(jsonError);
                        });
                        }
                    }
                    // an error occured sending the request, throw a webError
                    else if (completionHandler)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(webError);
                    });
                }
            }
        });
    }
}


//create MediaItems from data dictionary (feed dictionary) and load images as they arrive
- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters
{
    NSLog(@"%@", feedDictionary);
    
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray)
    {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem)
        {
            [tmpMediaItems addObject:mediaItem];
            //start downloading images as they arrive
            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"])
    {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    }
    else if (parameters[@"max_id"])
    {
    // This was an infinite scroll request
    
        if (tmpMediaItems.count == 0)
        {
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        }
        else
        {
            [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        }
    }
    else
    {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    //save images when a download completes
    [self saveImages];
}


- (void) saveImages {
    
    if (self.mediaItems.count > 0) {
        
        // Write the changes to disk on background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            
//          NSDataWritingAtomic ensures a complete file is saved. Without it, we might corrupt our file if the app crashes while writing to disk.
//          NSDataWritingFileProtectionCompleteUnlessOpen encrypts the data. This helps protect the user's privacy.
            
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
        
    }
}

- (void) downloadImageForMediaItem:(Media *)mediaItem
{
    if (mediaItem.mediaURL && !mediaItem.image)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            
            NSURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData)
            {
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image)
                {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                    });
                }
            }
            else
            {
                NSLog(@"Error downloading image: %@", error);
            }
        });
    }
}

#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

#pragma mark - Mutable Accessor methods

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}


#pragma mark NSKeyedArchiver

//create full path to a file given a filename
- (NSString *) pathForFilename:(NSString *) filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}


@end
