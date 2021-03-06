//
//  PostCollectionViewCell.m
//  Blocstagram
//
//  Created by Melissa Boring on 11/16/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "PostCollectionViewCell.h"

@interface PostCollectionViewCell()

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;;

@end

@implementation PostCollectionViewCell



-(id)initWithFrame:(CGRect)frame
{
     if (self = [super initWithFrame:frame] )
     {
        static NSInteger imageViewTag = 1000;
        static NSInteger labelTag = 1001;

        self.thumbnail =  [[UIImageView alloc] init];
        self.thumbnail = [self.contentView viewWithTag:imageViewTag];
        self.label = (UILabel *)[self.contentView viewWithTag:labelTag];

     //   self.flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView;
        CGFloat thumbnailEdgeSize = self.flowLayout.itemSize.width;

        if (!self.thumbnail) {
            self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
            self.thumbnail.tag = imageViewTag;
            self.thumbnail.clipsToBounds = YES;

            [self.contentView addSubview:self.thumbnail];
        }

        if (!self.label) {
            self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, 50, 20)];
            self.label.tag = labelTag;
            self.label.textAlignment = NSTextAlignmentCenter;
            self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
            [self.contentView addSubview:self.label];
        }
     }
    
    return self;

}

@end
