//
//  UIImage+ImageUtilities.m
//  Blocstagram
//
//  Created by Melissa Boring on 11/9/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "UIImage+ImageUtilities.h"

@implementation UIImage (ImageUtilities)



- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect
{
    //normalize the image to start with ....
    // Do nothing if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return [self copy];
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    
    //CGAffineTransform data structure represents a matrix used for affine transformations
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    //rotate
    switch (self.imageOrientation)
    {
            //same code is executed for UIImageOrientationDown and UIImageOrientationDownMirrored
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            
            //Returns an affine transformation matrix constructed by translating an existing affine transform.
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            
            //constructed by rotating an existing affine transform
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    //flip
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGFloat scaleFactor = self.scale;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             self.size.width * scaleFactor,
                                             self.size.height * scaleFactor,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    
    //Changes the scale of the user coordinate system in a context.
    CGContextScaleCTM(ctx, scaleFactor, scaleFactor);
    
    //Transforms the user coordinate system in a context using a specified matrix.
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    
    // Create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg scale:scaleFactor orientation:UIImageOrientationUp];
    


    //resize an image to the aspect ratio of the screen in order to make the cropping rectangle accurate
    CGFloat horizontalRatio = size.width / self.size.width;
    CGFloat verticalRatio = size.height / self.size.height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(self.size.width * ratio * self.scale, self.size.height * ratio * self.scale);
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = img.CGImage;
    
    ctx = CGBitmapContextCreate(NULL,
                 newRect.size.width,
                 newRect.size.height,
                 CGImageGetBitsPerComponent(imageRef),
                 0,
                 CGImageGetColorSpace(imageRef),
                 CGImageGetBitmapInfo(imageRef));
    
    // Draw into the context; this scales the image
    CGContextDrawImage(ctx, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(ctx);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(newImageRef);
    
//    //crop to the rectangle
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    
   // rect.origin.x = (CGRectGetMinX(rect) + (newImage.size.width - CGRectGetWidth(rect)) / 2);
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(newImage.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:croppedImageRef scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(croppedImageRef);
    return image;
}

@end

