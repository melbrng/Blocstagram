//
//  MediaTableViewCellTests.m
//  Blocstagram
//
//  Created by Melissa Boring on 12/2/15.
//  Copyright © 2015 Bloc. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "Media.h"
#import "MediaTableViewCell.h"

@interface MediaTableViewCellTests : XCTestCase

@property (strong,nonatomic)NSMutableArray *randomMediaItems ;
//@property  (strong,nonatomic)MediaTableViewCell *cell;

@end

@implementation MediaTableViewCellTests

- (void)setUp {
    [super setUp];
    self.randomMediaItems = [NSMutableArray array];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    for (int i = 1; i <= 10; i++) {
        NSString *imageName = [bundle pathForResource:[NSString stringWithFormat:@"%d", i] ofType:@"png"];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image) {
            Media *media = [[Media alloc] init];
            media.image = image;
            
            media.comments = [NSArray arrayWithObjects:@"Test Comment", nil];
            
            [self.randomMediaItems addObject:media];
        }
    }
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    for(Media *mediaItem in self.randomMediaItems)
    {
        CGFloat mediaHeight = mediaItem.image.size.height;
        
        CGFloat cellHeight =[MediaTableViewCell heightForMediaItem:mediaItem width:10.0];

        
    }
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end