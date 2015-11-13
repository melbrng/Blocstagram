//
//  ImageViewController.h
//  Blocstagram
//
//  Created by Melissa Boring on 11/13/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property(strong, nonatomic) UIImage *image;

- (instancetype) initWithImage:(UIImage *)image;

@end
