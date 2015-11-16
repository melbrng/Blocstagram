//
//  CropImageViewController.m
//  Blocstagram
//
//  Created by Melissa Boring on 11/14/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropBox.h"
#import "Media.h"
#import "UIImage+ImageUtilities.h"

@interface CropImageViewController ()

@property (nonatomic, strong) CropBox *cropBox;
@property (nonatomic, assign) BOOL hasLoadedOnce;
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@end

@implementation CropImageViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.media = [[Media alloc] init];
        self.media.image = sourceImage;
        
        self.cropBox = [CropBox new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createViews];
    [self addViewsToViewHierarchy];
    
    self.view.clipsToBounds = YES;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop command") style:UIBarButtonItemStyleDone target:self action:@selector(cropPressed:)];
    
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil]);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
}

- (void) addViewsToViewHierarchy
{
    NSMutableArray *views = [@[self.cropBox,self.topView, self.bottomView] mutableCopy];
    
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //CGRect cropRect = CGRectZero;
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    //cropRect.size = CGSizeMake(edgeSize, edgeSize);
    
    CGSize size = self.view.frame.size;
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    self.cropBox.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), width, width);
    
    //self.cropBox.frame = cropRect;
    self.cropBox.center = CGPointMake(size.width / 2, size.height / 2);
    self.scrollView.frame = self.cropBox.frame;
    self.scrollView.clipsToBounds = NO;
    
    [self recalculateZoomScale];
    
    if (self.hasLoadedOnce == NO) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
}


- (void) createViews
{
    self.topView = [UIToolbar new];
    self.bottomView = [UIToolbar new];
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
}

- (void) cropPressed:(UIBarButtonItem *)sender {
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.delegate cropControllerFinishedWithImage:scrollViewCrop];
}

@end
