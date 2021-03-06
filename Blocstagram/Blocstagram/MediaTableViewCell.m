//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Melissa Boring on 10/16/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "LikeButton.h"
#import "ComposeCommentView.h"

@interface MediaTableViewCell () <UIGestureRecognizerDelegate, ComposeCommentViewDelegate>

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *reloadImageTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, strong) LikeButton *likeButton;
@property (nonatomic, strong) ComposeCommentView *commentView;

@property (nonatomic, strong) NSArray *horizontallyRegularConstraints;
@property (nonatomic, strong) NSArray *horizontallyCompactConstraints;


@property (nonatomic, strong) UILabel *numberOfLikesLabel;


@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *commentOrange;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;
static NSParagraphStyle *rightAlignParagraphStyle;
static NSNumber *kernValue;

@implementation MediaTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        self.mediaImageView.userInteractionEnabled = YES;
        
        //add gesture recognizers
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.reloadImageTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTouchPressed:)];
        self.reloadImageTapGestureRecognizer.delegate = self;
        [self.reloadImageTapGestureRecognizer setNumberOfTouchesRequired:2];
        [self.mediaImageView addGestureRecognizer:self.reloadImageTapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        self.numberOfLikesLabel = [[UILabel alloc] init];
        self.numberOfLikesLabel.numberOfLines = 0;
        self.numberOfLikesLabel.backgroundColor = usernameLabelGray;
        self.numberOfLikesLabel.textAlignment = NSTextAlignmentCenter;
        self.numberOfLikesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16];
        
        self.contentView.backgroundColor = usernameLabelGray;
        
        self.commentView = [[ComposeCommentView alloc] init];
        self.commentView.delegate = self;
        
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.numberOfLikesLabel, self.commentView])
        {
            [self.contentView addSubview:view];
            //set to NO when working with auto layout
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _numberOfLikesLabel,_commentView);
        
        self.horizontallyCompactConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320];
        NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:0
                                                                               toItem:_mediaImageView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1
                                                                             constant:0];
        
        self.horizontallyRegularConstraints = @[widthConstraint, centerConstraint];
        
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
        {
            /* It's compact! */
            [self.contentView addConstraints:self.horizontallyCompactConstraints];
        }
        else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
        {
            /* It's regular! */
            [self.contentView addConstraints:self.horizontallyRegularConstraints];
        }
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_numberOfLikesLabel(==38)][_likeButton(==38)]|" options:kNilOptions metrics:nil views:viewDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentView]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView]-(==15)-[_numberOfLikesLabel]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_likeButton]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        self.imageHeightConstraint.identifier = @"Image height constraint";
        
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Username and caption label height constraint";
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
        self.commentLabelHeightConstraint.identifier = @"Comment label height constraint";
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
        
        
    }
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:NO animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
    
    // Configure the view for the selected state
}

- (void) setMediaItem:(Media *)mediaItem
{
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaItem.likeState;
    self.numberOfLikesLabel.text =self.mediaItem.numberOfLikes.stringValue;
    self.commentView.text = mediaItem.temporaryComment;
    
}

//CLASS METHOD (notice the +)
//called once and only once per class. Any class may implement load. The method is executed before anything else happens when the class is first used.

+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
    commentOrange = [UIColor colorWithRed:0.898 green:0.580 blue:0.0 alpha:1]; /*#e59400*/
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1]; /*#58506d*/
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    //where ends of the lines should stop. A negative value indicates the right-most edge
    mutableParagraphStyle.tailIndent = -20.0;
    //how far each paragraph should be from the previous
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    paragraphStyle = mutableParagraphStyle;
    
    
    NSMutableParagraphStyle *alignmentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    alignmentParagraphStyle.headIndent = 20.0;
    alignmentParagraphStyle.firstLineHeadIndent = 20.0;
    //where ends of the lines should stop. A negative value indicates the right-most edge
    alignmentParagraphStyle.tailIndent = -20.0;
    //how far each paragraph should be from the previous
    alignmentParagraphStyle.paragraphSpacingBefore = 5;
    alignmentParagraphStyle.alignment = NSTextAlignmentRight;
    rightAlignParagraphStyle = alignmentParagraphStyle;
    
    kernValue = [NSNumber numberWithFloat:3.0];
}

#pragma mark - Liking

- (void) likePressed:(UIButton *)sender
{
    [self.delegate cellDidPressLikeButton:self];
}


#pragma mark Attributed Strings

- (NSAttributedString *) usernameAndCaptionString
{
    
    CGFloat usernameFontSize = 15;
    
    // Make a string that says "username caption"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // Make an attributed string, with the "username" bold
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    // get the range of the username and caption
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    
    NSRange captionRange = [baseString rangeOfString:self.mediaItem.caption];
    
    //bold the username
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    
    //and purple the username
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    //and set the kern(space between letters)
    [mutableUsernameAndCaptionString addAttribute:NSKernAttributeName value:kernValue range:captionRange];
    
    return mutableUsernameAndCaptionString;
}

- (NSAttributedString *) commentString
{
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments)
    {
        NSUInteger index = [self.mediaItem.comments indexOfObject:comment];
        NSUInteger everyOtherIndex = ( index % 2 ) ;
        NSMutableAttributedString *oneCommentString;
        
        // Make a string that says "username comment" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        //identify every other comment and right align its paragraph
        if (everyOtherIndex == 1)
        {
            
            oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : rightAlignParagraphStyle}];
            
        }
        
        //otherwise left aligned
        else
        {
            oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        }
        
        // Make an attributed string, with the "username" bold
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        //identify first comment and set its color to orange
        if (index == 0)
        {
            //get its range
            NSRange textRange = [baseString rangeOfString:comment.text];
            
            //set its color attribute
            [oneCommentString addAttribute:NSForegroundColorAttributeName value:commentOrange range:textRange];
            
        }
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}



#pragma mark Layout the Subviews

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    // Before layout, calculate the intrinsic size of the labels (the size they "want" to be), and add 20 to the height for some vertical padding.
    //as wide as the view bounds and as high as CGFLOAT_MAX?
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height == 0 ? 0 : usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height == 0 ? 0 : commentLabelSize.height + 20;
    
    if (self.mediaItem.image.size.width > 0 && CGRectGetWidth(self.contentView.bounds) > 0)
    {
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
        {
            /* It's compact! */
            self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
        }
        else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
        {
            /* It's regular! */
            self.imageHeightConstraint.constant = 320;
        }
    }
    else
    {
        self.imageHeightConstraint.constant = 0;
    }
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);
}

- (void) traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
    {
        /* It's compact! */
        [self.contentView removeConstraints:self.horizontallyRegularConstraints];
        [self.contentView addConstraints:self.horizontallyCompactConstraints];
    }
    else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
    {
        /* It's regular */
        [self.contentView removeConstraints:self.horizontallyCompactConstraints];
        [self.contentView addConstraints:self.horizontallyRegularConstraints];
    }
}

 + (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width traitCollection:(UITraitCollection *) traitCollection
{
    
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    
    // Give it the media item
    layoutCell.mediaItem = mediaItem;
    
    // Set it to the given width, and the maximum possible height
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));

    
    layoutCell.overrideTraitCollection = traitCollection;
    
    // Make it adjust the image view and labels
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // The height will be wherever the bottom of the comment view is, plus a little padding
    return CGRectGetMaxY(layoutCell.commentView.frame) + 20.0f;
}

//override traitCollection
- (UITraitCollection *) traitCollection
{
    if (self.overrideTraitCollection)
    {
        return self.overrideTraitCollection;
    }
    
    return [super traitCollection];
}


#pragma mark - Image View Gestures

- (void) tapFired:(UITapGestureRecognizer *)sender
{
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}


//We could alternatively check for UIGestureRecognizerStateRecognized, but then the method wouldn't
//get called until the user lifts their finger.
//(And if we don't check at all, the delegate method will get called twice:
// once when the recognizer begins, and again when the user lifts their finger.)
- (void) longPressFired:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

- (void) doubleTouchPressed:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self.delegate cell:self didDoubleTouchImageView:self.mediaImageView];
    }
}

#pragma mark - UIGestureRecognizerDelegate

//gesture recognizer only fires while cell isn't in editing mode
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.isEditing == NO;
}

#pragma mark - ComposeCommentViewDelegate

- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender
{
    [self.delegate cell:self didComposeComment:self.mediaItem.temporaryComment];
}

- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text
{
    self.mediaItem.temporaryComment = text;
}

- (void) commentViewWillStartEditing:(ComposeCommentView *)sender
{
    [self.delegate cellWillStartComposingComment:self];
}

- (void) stopComposingComment
{
    [self.commentView stopComposingComment];
}
@end
