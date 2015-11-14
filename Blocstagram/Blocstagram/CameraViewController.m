//
//  CameraViewController.m
//  Blocstagram
//
//  Created by Melissa Boring on 11/9/15.
//  Copyright © 2015 Bloc. All rights reserved.
//
#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CameraToolbar.h"
#import "UIImage+ImageUtilities.h"
#import "CropBox.h"
#import "ImageLibraryViewController.h"


@interface CameraViewController () <CameraToolbarDelegate, ImageLibraryViewControllerDelegate>

@property (nonatomic, strong) UIView *imagePreview;

//coordinates data from inputs (cameras and microphones) to the outputs (movie files and still images)
@property (nonatomic, strong) AVCaptureSession *session;
//show the user the image from the camera
//Layers represent visual content. A layer is represented by the CALayer class (or subclasses like CAShapeLayer)
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
//captures still images from the capture session's input (camera)
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

/*
 horizontalLines and verticalLines will contain thin, white UIViews that will compose a 3x3 photo grid over the photo capture area.
 
 topView and bottomView are UIToolbars. Toolbars are typically used for displaying small buttons, but we're just using their unique translucent effect.
 
 cameraToolbar will store the camera toolbar we created earlier in this checkpoint
 */

@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;
@property (nonatomic, strong) CropBox *cropBox;
@property (nonatomic, strong) CameraToolbar *cameraToolbar;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViews];
    [self addViewsToViewHierarchy];
    [self setupImageCapture];
    [self createCancelButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) createViews {
    self.imagePreview = [UIView new];
    self.topView = [UIToolbar new];
    self.bottomView = [UIToolbar new];
    self.cameraToolbar = [[CameraToolbar alloc] initWithImageNames:@[@"rotate", @"road"]];
    self.cameraToolbar.delegate = self;
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
    self.cropBox = [CropBox new];
}

//Order is important: views added later will be on top
- (void) addViewsToViewHierarchy {
     NSMutableArray *views = [@[self.imagePreview, self.cropBox, self.topView, self.bottomView] mutableCopy];
    [views addObject:self.cameraToolbar];
    
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
}

- (void) setupImageCapture {
    // create a capture session, which mediates between the camera and output layer
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    //display the camera content
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.masksToBounds = YES;
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    // request permission to use the camera
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //accepted or not?
            if (granted) {
                // create device
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                
                // camera provides data to the session through capturedevieinput
                NSError *error = nil;
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if (!input) {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
                    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        [self.delegate cameraViewController:self didCompleteWithImage:nil];
                    }]];
                    
                    [self presentViewController:alertVC animated:YES completion:nil];
                } else {
                    // add input to our session, create still image output that saves JPEG files and start running session
                    
                    [self.session addInput:input];
                    
                    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                    self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
                    
                    [self.session addOutput:self.stillImageOutput];
                    
                    [self.session startRunning];
                }
            }
            //if anything goes wrong we tell delegate no image was obtained
            else
            {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera Permission Denied", @"camera permission denied title")
                                                                                 message:NSLocalizedString(@"This app doesn't have permission to use the camera; please update your privacy settings.", @"camera permission denied recovery suggestion")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [self.delegate cameraViewController:self didCompleteWithImage:nil];
                }]];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        });
    }];
}

- (void) createCancelButton {
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - Event Handling

- (void) cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate cameraViewController:self didCompleteWithImage:nil];
}

- (void) rightButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    NSLog(@"Photo library button pressed.");
    
    ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
    imageLibraryVC.delegate = self;
    [self.navigationController pushViewController:imageLibraryVC animated:YES];
}


#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    self.cropBox.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), width, width);
    
    self.imagePreview.frame = self.view.bounds;
    self.captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    
    CGFloat cameraToolbarHeight = 100;
    self.cameraToolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - cameraToolbarHeight, width, cameraToolbarHeight);
}

#pragma mark - CameraToolbarDelegate

- (void) leftButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    AVCaptureDeviceInput *currentCameraInput = self.session.inputs.firstObject;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 1) {
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1) {
            newIndex = currentIndex + 1;
        }
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        
        if (newVideoInput) {
            UIView *fakeView = [self.imagePreview snapshotViewAfterScreenUpdates:YES];
            fakeView.frame = self.imagePreview.frame;
            [self.view insertSubview:fakeView aboveSubview:self.imagePreview];
            
            [self.session beginConfiguration];
            [self.session removeInput:currentCameraInput];
            [self.session addInput:newVideoInput];
            [self.session commitConfiguration];
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                fakeView.alpha = 0;
            } completion:^(BOOL finished) {
                [fakeView removeFromSuperview];
            }];
        }
    }
}


- (void) cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    AVCaptureConnection *videoConnection;
    
    // Find the right connection object
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //pass connection to output
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer) {
            
            //convert data into UIImage and scale
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            
            //fix orientation and resize
            image = [image imageWithFixedOrientation];
            image = [image imageResizedToMatchAspectRatioOfSize:self.captureVideoPreviewLayer.bounds.size];
            
            //calculate white square rect
            CGRect gridRect = self.cropBox.frame;
            CGRect cropRect = gridRect;
            cropRect.origin.x = (CGRectGetMinX(gridRect) + (image.size.width - CGRectGetWidth(gridRect)) / 2);

            //pass to category method to crop the image
            image = [image imageCroppedToRect:cropRect];
            
            //once cropped call delegate with the image
            //camera button should now capture correct image
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraViewController:self didCompleteWithImage:image];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [self.delegate cameraViewController:self didCompleteWithImage:nil];
                }]];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            });
            
        }
    }];
}


#pragma mark - ImageLibraryViewControllerDelegate

- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
    [self.delegate cameraViewController:self didCompleteWithImage:image];
}

@end
