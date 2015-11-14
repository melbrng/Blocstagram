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

@interface CameraViewController () <CameraToolbarDelegate>

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
@property (nonatomic, strong) NSArray *horizontalLines;
@property (nonatomic, strong) NSArray *verticalLines;
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@property (nonatomic, strong) CameraToolbar *cameraToolbar;

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createViews];
    [self addViewsToViewHierarchy];
    [self setupImageCapture];
    [self createCancelButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Views and Grid

- (void) createViews
{
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
}

//Order is important: views added later will be on top
- (void) addViewsToViewHierarchy
{
    NSMutableArray *views = [@[self.imagePreview, self.topView, self.bottomView] mutableCopy];
    [views addObjectsFromArray:self.horizontalLines];
    [views addObjectsFromArray:self.verticalLines];
    [views addObject:self.cameraToolbar];
    
    for (UIView *view in views)
    {
        [self.view addSubview:view];
    }
}

- (NSArray *) horizontalLines
{
    if (!_horizontalLines)
    {
        _horizontalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _horizontalLines;
}

- (NSArray *) verticalLines
{
    if (!_verticalLines)
    {
        _verticalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _verticalLines;
}

- (NSArray *) newArrayOfFourWhiteViews
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++)
    {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [array addObject:view];
    }
    
    return array;
}

#pragma mark - UIAlertController

//returns a AlertController
-(UIAlertController *) returnAlertControllerWithTitle:(NSString*)title andError:(NSString*)error andStyle:(UIAlertControllerStyle)style;
{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                        message:error
                        preferredStyle:style];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button")
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction *action) {
                                                  [self.delegate cameraViewController:self didCompleteWithImage:nil];
                                              }]];
    
    return alertVC;
}

#pragma mark - Image Capture

- (void) setupImageCapture
{
    // create a capture session, which mediates between the camera and output layer
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    //display the camera content
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.masksToBounds = YES;
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    // request permission to use the camera
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //accepted or not?
            if (granted)
            {
                // create device
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                
                // camera provides data to the session through capturedevieinput
                NSError *error = nil;
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                
                if (!input)
                {
                    
                    UIAlertController *alertVC = [self returnAlertControllerWithTitle:error.localizedDescription
                        andError:error.localizedRecoverySuggestion
                        andStyle:UIAlertControllerStyleAlert];
                    
                    [self presentViewController:alertVC animated:YES completion:nil];
                }
                else
                {
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
                
                UIAlertController *alertVC = [self returnAlertControllerWithTitle:NSLocalizedString(@"Camera Permission Denied", @"camera permission denied title")
                    andError:NSLocalizedString(@"This app doesn't have permission to use the camera; please update your privacy settings.", @"camera permission denied recovery suggestion")
                    andStyle:UIAlertControllerStyleAlert];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        });
    }];
}

- (void) createCancelButton
{
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - Event Handling

- (void) cancelPressed:(UIBarButtonItem *)sender
{
    [self.delegate cameraViewController:self didCompleteWithImage:nil];
}

- (void) rightButtonPressedOnToolbar:(CameraToolbar *)toolbar
{
    NSLog(@"Photo library button pressed.");
}


#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    
    CGFloat thirdOfWidth = width / 3;
    
    for (int i = 0; i < 4; i++)
    {
        UIView *horizontalLine = self.horizontalLines[i];
        UIView *verticalLine = self.verticalLines[i];
        
        horizontalLine.frame = CGRectMake(0, (i * thirdOfWidth) + CGRectGetMaxY(self.topView.frame), width, 0.5);
        
        CGRect verticalFrame = CGRectMake(i * thirdOfWidth, CGRectGetMaxY(self.topView.frame), 0.5, width);
        
        if (i == 3)
        {
            verticalFrame.origin.x -= 0.5;
        }
        
        verticalLine.frame = verticalFrame;
    }
    
    self.imagePreview.frame = self.view.bounds;
    self.captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    
    CGFloat cameraToolbarHeight = 100;
    self.cameraToolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - cameraToolbarHeight, width, cameraToolbarHeight);
}

#pragma mark - CameraToolbarDelegate

- (void) leftButtonPressedOnToolbar:(CameraToolbar *)toolbar
{
    AVCaptureDeviceInput *currentCameraInput = self.session.inputs.firstObject;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 1)
    {
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1)
        {
            newIndex = currentIndex + 1;
        }
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        
        if (newVideoInput)
        {
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


- (void) cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar
{
    AVCaptureConnection *videoConnection;
    
    // Find the right connection object
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in connection.inputPorts)
        {
            if ([port.mediaType isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //pass connection to output
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
    {
        if (imageSampleBuffer)
        {
            
            //convert data into UIImage and scale
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            
            //calculate white square rect
            UIView *leftLine = self.verticalLines.firstObject;
            UIView *rightLine = self.verticalLines.lastObject;
            UIView *topLine = self.horizontalLines.firstObject;
            UIView *bottomLine = self.horizontalLines.lastObject;
            
            CGRect gridRect = CGRectMake(CGRectGetMinX(leftLine.frame),
                                         CGRectGetMinY(topLine.frame),
                                         CGRectGetMaxX(rightLine.frame) - CGRectGetMinX(leftLine.frame),
                                         CGRectGetMinY(bottomLine.frame) - CGRectGetMinY(topLine.frame));
            
            CGRect cropRect = gridRect;

            //pass to category method to orient, scale and crop the image
            image = [image imageByScalingToSize:self.captureVideoPreviewLayer.bounds.size andCroppingWithRect:cropRect];
            
            //once cropped call delegate with the image
            //camera button should now capture correct image
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraViewController:self didCompleteWithImage:image];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{

                UIAlertController *alertVC = [self returnAlertControllerWithTitle:error.localizedDescription
                                                                         andError:error.localizedRecoverySuggestion
                                                                         andStyle:UIAlertControllerStyleAlert];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            });
            
        }
    }];
}


@end
