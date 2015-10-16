//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Melissa Boring on 10/16/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;

 + (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
