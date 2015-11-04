//
//  CircleSpinnerView.m
//  Blocstagram
//
//  Created by Melissa Boring on 11/4/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "CircleSpinnerView.h"

@interface CircleSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation CircleSpinnerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.strokeThickness = 1;
        self.radius = 12;
        self.strokeColor = [UIColor purpleColor];
    }
    
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

- (CAShapeLayer*)circleLayer
{
    if(!_circleLayer)
    {
        //center
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        //will contain spinning circle
        CGRect rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
        
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        
        //creating a CAShapeLayer - core animation layer made from bezier path
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.contentsScale = [[UIScreen mainScreen] scale];
        _circleLayer.frame = rect;
        //coreani uses CGColorRef instead of UIColor so convert
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = self.strokeColor.CGColor;
        _circleLayer.lineWidth = self.strokeThickness;
        //shape of ends of line
        _circleLayer.lineCap = kCALineCapRound;
        //shape of joins between parts of line
        _circleLayer.lineJoin = kCALineJoinBevel;
        //assign circular path to layer
        _circleLayer.path = smoothedPath.CGPath;
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask"] CGImage];
        maskLayer.frame = _circleLayer.bounds;
        _circleLayer.mask = maskLayer;
        
        //animate
        CFTimeInterval animationDuration = 1; //1 second
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]; //speed of movement will stay the same throughout the animation
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = @0; //one full
        animation.toValue = @(M_PI*2); // ~ turn
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY; //repeated infinite # of times
        animation.fillMode = kCAFillModeForwards; //what happens when animationis complete;leaves layer onscreen after animation
        animation.autoreverses = NO;
        [_circleLayer.mask addAnimation:animation forKey:@"rotate"];
        
        
        //animate the line that draws the circle itself
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_circleLayer addAnimation:animationGroup forKey:@"progress"];
        
    }
    return _circleLayer;
}

#pragma mark - View Positioning

//position the animation in the center of the view
- (void)layoutAnimatedLayer
{
    [self.layer addSublayer:self.circleLayer];
    
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

//subview can react to this method; ensures positioning?
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview != nil)
    {
        [self layoutAnimatedLayer];
    }
    else
    {
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
    }
}

//Update the position of the layer if the frame changes
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (self.superview != nil)
    {
        [self layoutAnimatedLayer];
    }
}

//if we change radius can affect positioning; override setter to recreate circle layer
- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    
    [self layoutAnimatedLayer];
}

//inform if we change color and thickness
- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    _circleLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness
{
    _strokeThickness = strokeThickness;
    _circleLayer.lineWidth = _strokeThickness;
}





@end
