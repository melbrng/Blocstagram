//
//  Media.h
//  Blocstagram
//
//  Created by Melissa Boring on 10/12/15.
//  Copyright © 2015 Bloc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MediaDownloadState) {
    MediaDownloadStateNeedsImage             = 0,
    MediaDownloadStateDownloadInProgress     = 1,
    MediaDownloadStateNonRecoverableError    = 2,
    MediaDownloadStateHasImage               = 3
};


@class User;

@interface Media : NSObject<NSCoding>

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;

//This property uses the assign keyword instead of strong.
//This is because MediaDownloadState (aka NSInteger) is a simple type, not an object.
@property (nonatomic, assign) MediaDownloadState downloadState;


- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary;
- (NSMutableArray*) itemsToShare;

@end
