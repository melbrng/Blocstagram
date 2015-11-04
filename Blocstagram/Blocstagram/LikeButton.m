//
//  LikeButton.m
//  Blocstagram
//
//  Created by Melissa Boring on 11/4/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "LikeButton.h"
#import "CircleSpinnerView.h"

#define kLikedStateImage @"heart-full"
#define kUnlikedStateImage @"heart-empty"

@interface LikeButton ()

@property (nonatomic, strong) CircleSpinnerView *spinnerView;

@end

@implementation LikeButton

- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        self.spinnerView = [[CircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //buffer between edge of button and content
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        //alignment of button's content
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        self.likeButtonState = LikeStateNotLiked;
    }
    
    return self;
}


//update frame when button's frame changes
- (void) layoutSubviews
{
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}

//update based on set state
- (void) setLikeButtonState:(LikeState)likeState
{
    _likeButtonState = likeState;
    
    NSString *imageName;
    
    switch (_likeButtonState)
    {
        case LikeStateLiked:
        case LikeStateUnliking:
            imageName = kLikedStateImage;
            break;
            
        case LikeStateNotLiked:
        case LikeStateLiking:
            imageName = kUnlikedStateImage;
    }
    
    switch (_likeButtonState)
    {
        case LikeStateLiking:
        case LikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
            
        case LikeStateLiked:
        case LikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

@end
