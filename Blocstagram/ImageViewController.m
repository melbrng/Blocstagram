//
//  ImageViewController.m
//  Blocstagram
//
//  Created by Melissa Boring on 11/13/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation ImageViewController

- (instancetype) initWithImage:(UIImage *)image {
    self = [super init];
    
    if (self) {
        self.image = image;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(backAction)];
    
    [self createView];
    [self addViewsToViewHierarchy];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void) createView
{
    self.imageView = [[UIImageView alloc]initWithImage:self.image];
                                        
}

- (void) addViewsToViewHierarchy
{
    [self.view addSubview:self.imageView];
}

-(void) backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
