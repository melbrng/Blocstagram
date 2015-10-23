//
//  DataSource.h
//  Blocstagram
//
//  Created by Melissa Boring on 10/12/15.
//  Copyright © 2015 Bloc. All rights reserved.
//
@class Media;

#import <Foundation/Foundation.h>

@interface DataSource : NSObject

+(instancetype) sharedInstance;
@property (nonatomic, strong, readonly) NSArray *mediaItems;

 - (void) deleteMediaItem:(Media *)item;

 - (void) insertMediaItem:(Media *)item;


@end
