//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Melissa Boring on 10/29/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"
#import "AppDelegate.h"

@interface MediaFullScreenViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>



//Any time you implement a pinch gesture, it's a good idea to implement a double-tap gesture too.
//Not only is it handy, but it's very helpful to disabled users who may be unable to pinch.
//(For example, some users are missing fingers, and paraplegic users may be using a stylus in their mouth.)

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *borderTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation MediaFullScreenViewController

- (instancetype) initWithMedia:(Media *)media {
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
   
    [window makeKeyAndVisible];
    self.borderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(borderTapFired:)];
    self.borderTap.cancelsTouchesInView = NO;
    self.borderTap.numberOfTapsRequired = 1;
    self.borderTap.delegate = self;
    [window addGestureRecognizer:self.borderTap];

    //create scroll view
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:self.scrollView];
    
    //create image and add as subview
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview:self.imageView];
    
    //content view size
    self.scrollView.contentSize = self.media.image.size;
    
    //initialize tap, doubletap, borderTap
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
//    requireGestureRecognizerToFail: allows one gesture recognizer to wait for another gesture recognizer to fail before it succeeds.
//    Without this line, it would be impossible to double-tap because the single tap gesture recognizer would fire before the
//    user had a chance to tap twice.
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton sizeToFit];
    [self.view addSubview:shareButton];
    
    CGFloat buttonWidth = shareButton.frame.size.width;
    CGFloat buttonHeight = shareButton.frame.size.height;
    shareButton.center = CGPointMake(self.view.bounds.size.width - buttonWidth, buttonHeight);
    [shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self centerScrollView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[[UIApplication sharedApplication] keyWindow] removeGestureRecognizer:self.borderTap];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //scroll view will take up view's space
    self.scrollView.frame = self.view.bounds;
    
    [self recalculateZoomScale];
}

- (void) recalculateZoomScale {
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    //allows subclasses to recalculate the zoom scale for scroll views that are zoomed out
    scrollViewContentSize.height /= self.scrollView.zoomScale;
    scrollViewContentSize.width /= self.scrollView.zoomScale;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    //whatever is smaller to it doesn't disappear
    self.scrollView.minimumZoomScale = minScale;
    
    //always be 1 (100%)
    self.scrollView.maximumZoomScale = 1;
}

- (void)centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - UIScrollViewDelegate
//tells scroll view which view to zoon in on
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

//calls center after user has changed zoom level
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
}


#pragma mark - Gesture Recognizers

- (void) tapFired:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) borderTapFired:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

    
}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender
{
    
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale)
    {
        //if zoom scaleis already as small as it can be double tapping will zoom in
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    }
    else
    {
        //if current zoom scale is larger zoom out to mimimum scale
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

-(void) shareButtonPressed: (UIButton *)button
{
    NSMutableArray *itemsToShare = self.media.itemsToShare;
    
    if (itemsToShare.count > 0)
    {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}
@end
