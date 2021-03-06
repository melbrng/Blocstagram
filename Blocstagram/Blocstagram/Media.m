//
//  Media.m
//  Blocstagram
//
//  Created by Melissa Boring on 10/12/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "Media.h"
#import "User.h"
#import "Comment.h"

@implementation Media

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary
{
    self = [super init];
    
    if (self)
    {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL)
        {
            self.mediaURL = standardResolutionImageURL;
            //set default download state. If not set it would be initialized to 0
            self.downloadState = MediaDownloadStateNeedsImage;
        }
        else
        {
            self.downloadState = MediaDownloadStateNonRecoverableError;

        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // Caption might be null (if there's no caption)
        if ([captionDictionary isKindOfClass:[NSDictionary class]])
        {
            self.caption = captionDictionary[@"text"];
            
        }
        else
        {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"])
        {
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
        }
        
        self.comments = commentsArray;
        
        //has user already liked image?
        BOOL userHasLiked = [mediaDictionary[@"user_has_liked"] boolValue];
        
        self.likeState = userHasLiked ? LikeStateLiked : LikeStateNotLiked;

    }
    
    return self;
}

-(NSMutableArray*)itemsToShare
{
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (self.caption.length > 0) {
        [itemsToShare addObject:self.caption];
    }
    
    if (self.image) {
        [itemsToShare addObject:self.image];
    }
    
    return itemsToShare;
}

-(void)countLikes
{
    if (self.likeState == LikeStateLiked)
    {
        int count = [self.numberOfLikes intValue] ? [self.numberOfLikes intValue] : 0;
        
        count += 1;
        
        self.numberOfLikes = [NSNumber numberWithInt:count];
    }
    
}

-(void)setNumberOfLikes:(NSNumber *)numberOfLikes
{
    _numberOfLikes = numberOfLikes;
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.mediaURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaURL))];
        
        //set image and the download state
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        if (self.image)
        {
            self.downloadState = MediaDownloadStateHasImage;
        }
        else if (self.mediaURL)
        {
            self.downloadState = MediaDownloadStateNeedsImage;
        }
        else
        {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }
        
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
        self.likeState = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeState))];
        self.numberOfLikes = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(numberOfLikes))];

    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.mediaURL forKey:NSStringFromSelector(@selector(mediaURL))];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.caption forKey:NSStringFromSelector(@selector(caption))];
    [aCoder encodeObject:self.comments forKey:NSStringFromSelector(@selector(comments))];
    [aCoder encodeInteger:self.likeState forKey:NSStringFromSelector(@selector(likeState))];
    [aCoder encodeObject:self.numberOfLikes forKey:NSStringFromSelector(@selector(numberOfLikes))];

}

@end
