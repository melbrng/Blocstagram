//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Melissa Boring on 10/12/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "MediaTableViewCell.h"
#import "MediaFullScreenViewController.h"
#import "CameraViewController.h"
#import "ImageLibraryViewController.h"
#import "PostToInstagramViewController.h"

@interface ImagesTableViewController ()<MediaTableViewCellDelegate, CameraViewControllerDelegate, ImageLibraryViewControllerDelegate>

@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustment;

@end

@implementation ImagesTableViewController

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle : style];
    
    if (self)
    {
        self.tableView.decelerationRate = 0.5f;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //create observer for KVO
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    //property of tableviewcontroller
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    //check for available photo capabilities
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
        self.navigationItem.rightBarButtonItem = cameraButton;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    
    if (indexPath)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    
}

//remove Observer right before self disappears
- (void) dealloc
{
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Completion handler

- (void) refreshControlDidFire:(UIRefreshControl *) sender
{
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error){
        
        [sender endRefreshing];
        
    }];
}

- (void) infiniteScrollIfNecessary
{
    // has scrolled to last photo?
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [DataSource sharedInstance].mediaItems.count - 1)
    {
        // The very last cell is on screen so call completion handler to request more photos
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}

-(void) loadVisibleImages
{
    
    NSArray *indexPath = [self.tableView indexPathsForVisibleRows];
    
    //initial load of tableView to load images for first visible
    if (self.tableView.dragging == YES )

    {
        for (NSIndexPath *x in indexPath)
        {
        
            Media *mediaItem = [[self items]objectAtIndex:x.row];
            
            if (mediaItem.downloadState == MediaDownloadStateNeedsImage)
            {
                [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

//uitableview is a child of uiscrollview
//method is called repeatedly so check to see if last image in the array has made it onto the screen
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self infiniteScrollIfNecessary];
        
    [self loadVisibleImages];

}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
    [self loadVisibleImages];
    
}

#pragma mark - KVO observing

//all KVO notifications are sent to this one method
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //is this update coming from Datasource? and is mediaItems the key?
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"])
    {
        // We know mediaItems changed.  Let's see what kind of change it is.
        NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        
//        NSKeyValueChangeSetting	The entire object has been replaced e.g. _mediaItems = [NSMutableArray array];	1
//        NSKeyValueChangeInsertion	An object has been added to the collection	2
//        NSKeyValueChangeRemoval	An object has been removed from the collection	3
//        NSKeyValueChangeReplacement	An object has been replaced within the collection	4
        
        if (kindOfChange == NSKeyValueChangeSetting)
        {
            // Someone set a brand new images array
            [self.tableView reloadData];
        }
        
        else if (kindOfChange == NSKeyValueChangeInsertion ||
               kindOfChange == NSKeyValueChangeRemoval ||
               kindOfChange == NSKeyValueChangeReplacement)
        {
            // We have an incremental change: inserted, deleted, or replaced images
            
            // Get a list of the index (or indices) that changed
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            // #1 - Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what the table view animation methods require)
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
            {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            // #2 - Call `beginUpdates` to tell the table view we're about to make changes
            [self.tableView beginUpdates];
            
            // Tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion)
            {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else if (kindOfChange == NSKeyValueChangeRemoval)
            {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else if (kindOfChange == NSKeyValueChangeReplacement)
            {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Tell the table view that we're done telling it about changes, and to complete the animation
            [self.tableView endUpdates];
            
        }
    }
    
}

-(NSArray*)items
{

    return [DataSource sharedInstance].mediaItems;

}

 #pragma mark - Camera, CameraViewControllerDelegate, and ImageLibraryViewControllerDelegate

- (void) handleImage:(UIImage *)image withNavigationController:(UINavigationController *)nav {
    if (image) {
        PostToInstagramViewController *postVC = [[PostToInstagramViewController alloc] initWithImage:image];
        
        [nav pushViewController:postVC animated:YES];
    } else {
        [nav dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) cameraPressed:(UIBarButtonItem *) sender {
    
    UIViewController *imageVC;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        cameraVC.delegate = self;
        imageVC = cameraVC;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
        imageLibraryVC.delegate = self;
        imageVC = imageLibraryVC;
    }
    
    if (imageVC) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    return;
}

- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image
{
    [self handleImage:image withNavigationController:imageLibraryViewController.navigationController];

}

- (void) cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image
{
    
    [self handleImage:image withNavigationController:cameraViewController.navigationController];
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self items].count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MediaTableViewCell *cell = (MediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}

//check for images right before the cell displays
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media *mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == MediaDownloadStateNeedsImage)
    {
        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    Media *item = [self items][indexPath.row];

    CGFloat height = [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
    
    return height;

}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];

    if (item.image)
    {
        return 450;
    }
    else
    {
        return 250;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
        [[DataSource sharedInstance] deleteMediaItem:item];
    }
}


#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {
    // Get the frame of the keyboard within self.view's coordinate system
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
    // Get the frame of the comment view in the same coordinate system
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
    CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
    CGFloat difference = commentViewY - keyboardY;
    
    if (difference > 0) {
        heightToScroll += difference;
    }
    
    if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
        // The two frames intersect (the keyboard would block the view)
        CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
        heightToScroll += CGRectGetHeight(intersectionRect);
    }
    
    if (heightToScroll > 0) {
        contentInsets.bottom += heightToScroll;
        scrollIndicatorInsets.bottom += heightToScroll;
        contentOffset.y += heightToScroll;
        
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }
    
    self.lastKeyboardAdjustment = heightToScroll;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    contentInsets.bottom -= self.lastKeyboardAdjustment;
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustment;
    
    NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    NSTimeInterval duration = durationNumber.doubleValue;
    UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
    UIViewAnimationOptions options = curve << 16;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    } completion:nil];
}

#pragma mark - MediaTableViewCellDelegate

- (void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView
{
    MediaFullScreenViewController *fullScreenVC = [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

- (void) cell:(MediaTableViewCell *)cell didDoubleTouchImageView:(UIImageView *)imageView
{
    [[DataSource sharedInstance] downloadImageForMediaItem:cell.mediaItem];
}

- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView
{
    NSMutableArray *itemsToShare = cell.mediaItem.itemsToShare;
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void) cellDidPressLikeButton:(MediaTableViewCell *)cell
{
    Media *item = cell.mediaItem;

    [[DataSource sharedInstance] toggleLikeOnMediaItem:item withCompletionHandler:^{
        
        // If the user scrolls and the cell is reused to display a different media item, we no longer want to update the button
        if (cell.mediaItem == item) {
            cell.mediaItem = item;
        }
    }];
    
    cell.mediaItem = item;
    
}

#pragma mark - Comment Delegates

- (void) cellWillStartComposingComment:(MediaTableViewCell *)cell
{
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}

- (void) cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment
{
     [[DataSource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
}


@end
