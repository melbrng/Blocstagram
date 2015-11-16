//
//  PostCollectionViewCell.h
//  Blocstagram
//
//  Created by Melissa Boring on 11/16/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *thumbnail;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UICollectionView *filterCollectionView;

@end
