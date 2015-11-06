//
//  DataSource.h
//  Blocstagram
//
//  Created by Melissa Boring on 10/12/15.
//  Copyright © 2015 Bloc. All rights reserved.
//
@class Media;

#import <Foundation/Foundation.h>

typedef void (^NewItemCompletionBlock)(NSError *error);


@interface DataSource : NSObject


@property (nonatomic, strong, readonly) NSString *accessToken;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

+(instancetype) sharedInstance;

+ (NSString *) instagramClientID;

- (void) deleteMediaItem:(Media *)item;

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

- (void) downloadImageForMediaItem:(Media *)mediaItem;

- (void) toggleLikeOnMediaItem:(Media *)mediaItem withCompletionHandler:(void (^)(void))completionHandler;


- (void) commentOnMediaItem:(Media *)mediaItem withCommentText:(NSString *)commentText;

@end
