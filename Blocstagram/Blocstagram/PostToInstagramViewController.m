//
//  PostToInstagramViewController.m
//  Blocstagram
//
//  Created by Melissa Boring on 11/14/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "PostToInstagramViewController.h"
#import "PostCollectionViewCell.h"

@interface PostToInstagramViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, strong) NSOperationQueue *photoFilterOperationQueue;
@property (nonatomic, strong) UICollectionView *filterCollectionView;

@property (nonatomic, strong) NSMutableArray *filterImages;
@property (nonatomic, strong) NSMutableArray *filterTitles;

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIBarButtonItem *sendBarButton;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;


@end

@implementation PostToInstagramViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.sourceImage = sourceImage;
        self.previewImageView = [[UIImageView alloc] initWithImage:self.sourceImage];
        
        self.photoFilterOperationQueue = [[NSOperationQueue alloc] init];
        self.photoFilterOperationQueue.maxConcurrentOperationCount= 1;
        
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(44, 64);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        
        self.filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.filterCollectionView.dataSource = self;
        self.filterCollectionView.delegate = self;
        self.filterCollectionView.showsHorizontalScrollIndicator = NO;
        
        self.filterImages = [NSMutableArray arrayWithObject:sourceImage];
        self.filterTitles = [NSMutableArray arrayWithObject:NSLocalizedString(@"None", @"Label for when no filter is applied to a photo")];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.sendButton.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1]; /*#58516c*/
        self.sendButton.layer.cornerRadius = 5;
        [self.sendButton setAttributedTitle:[self sendAttributedString] forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.sendBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send button") style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonPressed:)];
        
        [self addFiltersToQueue];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.previewImageView];
    [self.view addSubview:self.filterCollectionView];
    
    if (CGRectGetHeight(self.view.frame) > 500) {
        [self.view addSubview:self.sendButton];
    } else {
        self.navigationItem.rightBarButtonItem = self.sendBarButton;
    }
    
    //register custom cell
    [self.filterCollectionView registerClass:[PostCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.filterCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = NSLocalizedString(@"Apply Filter", @"apply filter view title");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    self.previewImageView.frame = CGRectMake(0, self.topLayoutGuide.length, edgeSize, edgeSize);
    
    CGFloat buttonHeight = 50;
    CGFloat buffer = 10;
    
    CGFloat filterViewYOrigin = CGRectGetMaxY(self.previewImageView.frame) + buffer;
    CGFloat filterViewHeight;
    
    if (CGRectGetHeight(self.view.frame) > 500) {
        self.sendButton.frame = CGRectMake(buffer, CGRectGetHeight(self.view.frame) - buffer - buttonHeight, CGRectGetWidth(self.view.frame) - 2 * buffer, buttonHeight);
        
        filterViewHeight = CGRectGetHeight(self.view.frame) - filterViewYOrigin - buffer - buffer - CGRectGetHeight(self.sendButton.frame);
    } else {
        filterViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.previewImageView.frame) - buffer - buffer;
    }
    
    self.filterCollectionView.frame = CGRectMake(0, filterViewYOrigin, CGRectGetWidth(self.view.frame), filterViewHeight);
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(CGRectGetHeight(self.filterCollectionView.frame) - 20, CGRectGetHeight(self.filterCollectionView.frame));
}

#pragma mark - Buttons

- (NSAttributedString *) sendAttributedString {
    NSString *baseString = NSLocalizedString(@"SEND TO INSTAGRAM", @"send to Instagram button text");
    NSRange range = [baseString rangeOfString:baseString];
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    [commentString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13] range:range];
    [commentString addAttribute:NSKernAttributeName value:@1.3 range:range];
    [commentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1] range:range];
    
    return commentString;
}


#pragma mark - UICollectionView delegate and data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterImages.count;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
//    static NSInteger imageViewTag = 1000;
//    static NSInteger labelTag = 1001;
//    
//    UIImageView *thumbnail = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
//    UILabel *label = (UILabel *)[cell.contentView viewWithTag:labelTag];
//    
//    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;
//    CGFloat thumbnailEdgeSize = flowLayout.itemSize.width;
//    
//    if (!thumbnail) {
//        thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
//        thumbnail.contentMode = UIViewContentModeScaleAspectFill;
//        thumbnail.tag = imageViewTag;
//        thumbnail.clipsToBounds = YES;
//        
//        [cell.contentView addSubview:thumbnail];
//    }
//    
//    if (!label) {
//        label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
//        label.tag = labelTag;
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
//        [cell.contentView addSubview:label];
//    }
//
    
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.collectionViewLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;
    cell.thumbnail.backgroundColor = [UIColor yellowColor];
    cell.thumbnail.image = self.filterImages[indexPath.row];
    cell.label.text = self.filterTitles[indexPath.row];
    NSLog(@"labeltext : %@",cell.label.text);
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.previewImageView.image = self.filterImages[indexPath.row];
}

#pragma mark - Send Photo

- (void) sendButtonPressed:(id)sender {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    
    UIAlertController *alertVC;
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        alertVC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Add a caption and send your image in the Instagram app.", @"send image instructions") preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Caption", @"Caption");
        }];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel button") style:UIAlertActionStyleCancel handler:nil]];
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send", @"Send button") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textField = alertVC.textFields[0];
            [self sendImageToInstagramWithCaption:textField.text];
        }]];
    } else {
        alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Instagram App", nil) message:NSLocalizedString(@"Add a caption and send your image in the Instagram app.", @"send image instructions") preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:nil]];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void) sendImageToInstagramWithCaption:(NSString *)caption {
    NSData *imagedata = UIImageJPEGRepresentation(self.previewImageView.image, 0.9f);
    
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"blocstagram"] URLByAppendingPathExtension:@"igo"];
    
    BOOL success = [imagedata writeToURL:fileURL atomically:YES];
    
    if (!success) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't save image", nil) message:NSLocalizedString(@"Your cropped and filtered photo couldn't be saved. Make sure you have enough disk space and try again.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentController.UTI = @"com.instagram.exclusivegram";
    self.documentController.delegate = self;
    
    if (caption.length > 0) {
        self.documentController.annotation = @{@"InstagramCaption": caption};
    }
    
    if (self.sendButton.superview) {
        [self.documentController presentOpenInMenuFromRect:self.sendButton.bounds inView:self.sendButton animated:YES];
    } else {
        [self.documentController presentOpenInMenuFromBarButtonItem:self.sendBarButton animated:YES];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Filters

//handles finished filters and add them to the collection view
- (void) addCIImageToCollectionView:(CIImage *)CIImage withFilterTitle:(NSString *)filterTitle {
    
    //convert to UIImage - forces the UIImage to draw and saves it
    UIImage *image = [UIImage imageWithCIImage:CIImage scale:self.sourceImage.scale orientation:self.sourceImage.imageOrientation];
    
    if (image) {
        
        // Decompress image
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawAtPoint:CGPointZero];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //adds image on the main thread and alerts collection view that a new item is available
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger newIndex = self.filterImages.count;
            
            [self.filterImages addObject:image];
            [self.filterTitles addObject:filterTitle];
            
            [self.filterCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:0]]];
        });
    }
}

//add filters to NSOperationQueue for scheduling pieces of long-running code
- (void) addFiltersToQueue
{
    CIImage *sourceCIImage = [CIImage imageWithCGImage:self.sourceImage.CGImage];
    CGFloat h = self.sourceImage.size.height;

    
    // Noir filter
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *noirFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
        
        if (noirFilter) {
            [noirFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:noirFilter.outputImage withFilterTitle:NSLocalizedString(@"Noir", @"Noir Filter")];
        }
    }];
    
//    Create a Blurred Version of the image
//    Set the input parameters of the CIGaussianBlur filter as follows:
//    Set inputImage to the image you want to process.
//    Set inputRadius to 10.0 (which is the default value).
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *gaussianBlueFilter = [CIFilter filterWithName:@"CIGaussianBlue"];

        [gaussianBlueFilter setValue:sourceCIImage forKey:kCIInputImageKey];
        [gaussianBlueFilter setValue:@10.0 forKey:kCIAttributeTypeDistance];
        CIImage *blurredImage = gaussianBlueFilter.outputImage;
    
        //    Create Two Linear Gradients
        //    Create a linear gradient from a single color (such as green or gray) that varies from top to bottom. Set the input parameters of CILinearGradient as follows:
        CIFilter *linearGradientFilter = [CIFilter filterWithName:@"CILinearGradient" keysAndValues:
                                      @"inputPoint0", [CIVector vectorWithX:0 Y:(0.75 * h)],
                                      @"inputPoint1", [CIVector vectorWithX:0 Y:(0.5 * h)],
                                      @"inputColor0", [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0],
                                      @"inputColor1", [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.0],
                                      nil];


        //    Create a green linear gradient that varies from bottom to top. Set the input parameters of CILinearGradient as follows:
        CIFilter *greenGradientFilter = [CIFilter filterWithName:@"CILinearGradient" keysAndValues:
                                      @"inputPoint0", [CIVector vectorWithX:0 Y:(0.25 * h)],
                                      @"inputPoint1", [CIVector vectorWithX:0 Y:(0.5 * h)],
                                      @"inputColor0", [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0],
                                      @"inputColor1", [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.0],
                                      nil];
 
        //    Create a Mask from the Linear Gradients
        //    Set inputImage to the first linear gradient you created.
        CIImage *inputImage = linearGradientFilter.outputImage;
        
        //  Set inputBackgroundImage to the second linear gradient you created.
        CIImage *backgroundImage = greenGradientFilter.outputImage;
        
        //    To create a mask, set the input parameters of the CIAdditionCompositing filter as follows:
        CIFilter *composite = [CIFilter filterWithName:@"CIAdditionCompositing"];
        [composite setValue:inputImage forKey:kCIInputImageKey];
        [composite setValue:backgroundImage forKey:kCIInputBackgroundImageKey];
        CIImage *maskedImage = composite.outputImage;
        
//        Combine the Blurred Image, Source Image, and the Gradients
//        The final step is to use the CIBlendWithMask filter, setting the input parameters as follows:
//        Set inputImage to the blurred version of the image.
//        Set inputBackgroundImage to the original, unprocessed image.
//        Set inputMaskImage to the mask, that is, the combined gradients.
//        The mask will affect only the outer portion of an image.
//        The transparent portions of the mask will show through the original, unprocessed image. The opaque portions of the mask allow the blurred image to show.
        
        CIFilter *blend = [CIFilter filterWithName:@"CIBlendWithMask"];
        [blend setValue:blurredImage forKey:kCIInputImageKey];
        [blend setValue:sourceCIImage forKey:kCIInputBackgroundImageKey];
        [blend setValue:maskedImage forKey:kCIInputMaskImageKey];
        
        CIImage *miniatureImage = blend.outputImage;
        
        [self addCIImageToCollectionView:miniatureImage withFilterTitle:NSLocalizedString(@"Miniature", @"Min Filter")];
        
        
      }];

    

//    // Color Invert filter
//    [self.photoFilterOperationQueue addOperationWithBlock:^{
//        CIFilter *noirFilter = [CIFilter filterWithName:@"CIColorInvert"];
//        
//        if (noirFilter) {
//            [noirFilter setValue:sourceCIImage forKey:kCIInputImageKey];
//            [self addCIImageToCollectionView:noirFilter.outputImage withFilterTitle:NSLocalizedString(@"Invert", @"Invert Filter")];
//        }
//    }];
//    
//    // Zoom Blur filter
//    [self.photoFilterOperationQueue addOperationWithBlock:^{
//        CIFilter *noirFilter = [CIFilter filterWithName:@"CIZoomBlur"];
//        
//        if (noirFilter) {
//            [noirFilter setValue:sourceCIImage forKey:kCIInputImageKey];
//            [self addCIImageToCollectionView:noirFilter.outputImage withFilterTitle:NSLocalizedString(@"Blur", @"Blur Filter")];
//        }
//    }];
//
//
//    // Boom filter
//
//    [self.photoFilterOperationQueue addOperationWithBlock:^{
//        CIFilter *boomFilter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
//        
//        if (boomFilter) {
//            [boomFilter setValue:sourceCIImage forKey:kCIInputImageKey];
//            [self addCIImageToCollectionView:boomFilter.outputImage withFilterTitle:NSLocalizedString(@"Boom", @"Boom Filter")];
//        }
//    }];
//
//    // Warm filter
//
//    [self.photoFilterOperationQueue addOperationWithBlock:^{
//        CIFilter *warmFilter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
//        
//        if (warmFilter) {
//            [warmFilter setValue:sourceCIImage forKey:kCIInputImageKey];
//            [self addCIImageToCollectionView:warmFilter.outputImage withFilterTitle:NSLocalizedString(@"Warm", @"Warm Filter")];
//        }
//    }];
//
//    // Pixel filter
//
//    [self.photoFilterOperationQueue addOperationWithBlock:^{
//        CIFilter *pixelFilter = [CIFilter filterWithName:@"CIPixellate"];
//        
//        if (pixelFilter) {
//            [pixelFilter setValue:sourceCIImage forKey:kCIInputImageKey];
//            [self addCIImageToCollectionView:pixelFilter.outputImage withFilterTitle:NSLocalizedString(@"Pixel", @"Pixel Filter")];
//        }
//    }];
//
//    // Moody filter
//
//    [self.photoFilterOperationQueue addOperationWithBlock:^{
//        CIFilter *moodyFilter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
//        
//        if (moodyFilter) {
//            [moodyFilter setValue:sourceCIImage forKey:kCIInputImageKey];
//            [self addCIImageToCollectionView:moodyFilter.outputImage withFilterTitle:NSLocalizedString(@"Moody", @"Moody Filter")];
//        }
//    }];
//    
//    // Drunk filter
//    
//    [self.photoFilterOperationQueue addOperationWithBlock:^{
//        CIFilter *drunkFilter = [CIFilter filterWithName:@"CIConvolution5X5"];
//        CIFilter *tiltFilter = [CIFilter filterWithName:@"CIStraightenFilter"];
//        
//        if (drunkFilter) {
//            [drunkFilter setValue:sourceCIImage forKey:kCIInputImageKey];
//            
//            CIVector *drunkVector = [CIVector vectorWithString:@"[0.5 0 0 0 0 0 0 0 0 0.05 0 0 0 0 0 0 0 0 0 0 0.05 0 0 0 0.5]"];
//            [drunkFilter setValue:drunkVector forKeyPath:@"inputWeights"];
//            
//            CIImage *result = drunkFilter.outputImage;
//            
//            if (tiltFilter) {
//                [tiltFilter setValue:result forKeyPath:kCIInputImageKey];
//                [tiltFilter setValue:@0.2 forKeyPath:kCIInputAngleKey];
//                result = tiltFilter.outputImage;
//            }
//            
//            [self addCIImageToCollectionView:result withFilterTitle:NSLocalizedString(@"Drunk", @"Drunk Filter")];
//        }
//    }];
//    
//    
//    // Film filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        // CISepiaTone
        CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"];
        [sepiaFilter setValue:@1 forKey:kCIInputIntensityKey];
        [sepiaFilter setValue:sourceCIImage forKey:kCIInputImageKey];
    
        // color TV static
        CIFilter *randomFilter = [CIFilter filterWithName:@"CIRandomGenerator"];
        
        CIImage *randomImage = [CIFilter filterWithName:@"CIRandomGenerator"].outputImage;
        
        // stretch the image a little bit horizontally, and a lot vertically
        CIImage *otherRandomImage = [randomImage imageByApplyingTransform:CGAffineTransformMakeScale(1.5, 25.0)];
        
        // extract white specks
        CIFilter *whiteSpecks = [CIFilter filterWithName:@"CIColorMatrix" keysAndValues:kCIInputImageKey, randomImage,
                                 @"inputRVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputGVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputBVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputAVector", [CIVector vectorWithX:0.0 Y:0.01 Z:0.0 W:0.0],
                                 @"inputBiasVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                 nil];
        //extract vertical scratches
        CIFilter *darkScratches = [CIFilter filterWithName:@"CIColorMatrix" keysAndValues:kCIInputImageKey, otherRandomImage,
                                   @"inputRVector", [CIVector vectorWithX:3.659f Y:0.0 Z:0.0 W:0.0],
                                   @"inputGVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputBVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputAVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputBiasVector", [CIVector vectorWithX:0.0 Y:1.0 Z:1.0 W:1.0],
                                   nil];
        
        // combine the layers
        CIFilter *minimumComponent = [CIFilter filterWithName:@"CIMinimumComponent"];
        CIFilter *composite = [CIFilter filterWithName:@"CIMultiplyCompositing"];
        
        // ensure that those filters all exist
        if (sepiaFilter && randomFilter && whiteSpecks && darkScratches && minimumComponent && composite) {
            // Apply the sepia filter
            CIImage *sepiaImage = sepiaFilter.outputImage;
            
            // we crop it to the source image's size since the randomly generated image is infinite
            CIImage *whiteSpecksImage = [whiteSpecks.outputImage imageByCroppingToRect:sourceCIImage.extent];
            
            // create sepiaPlusWhiteSpecksImage by using CISourceOverCompositing to overlay the white specks on top of the sepia-toned image
            CIImage *sepiaPlusWhiteSpecksImage = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
                                                  kCIInputImageKey, whiteSpecksImage,
                                                  kCIInputBackgroundImageKey, sepiaImage,
                                                  nil].outputImage;
            
            // create darkScratchesImage and add it on top of the white specks
            CIImage *darkScratchesImage = [darkScratches.outputImage imageByCroppingToRect:sourceCIImage.extent];
            
            [minimumComponent setValue:darkScratchesImage forKey:kCIInputImageKey];
            darkScratchesImage = minimumComponent.outputImage;
            
            [composite setValue:sepiaPlusWhiteSpecksImage forKey:kCIInputImageKey];
            [composite setValue:darkScratchesImage forKey:kCIInputBackgroundImageKey];
            
            [self addCIImageToCollectionView:composite.outputImage withFilterTitle:NSLocalizedString(@"Film", @"Film Filter")];
        }
    }];

}
@end
