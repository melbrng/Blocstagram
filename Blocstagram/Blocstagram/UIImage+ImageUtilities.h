//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Melissa Boring on 11/9/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end
