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
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    NSDictionary *sourceDictionary= @{@"id": @"9999999",
                                      @"images" : @{@"standard_resolution" : @{@"url" : @"http://www.melbo.co"}},
                                      @"user_had_liked" : @"0",
                                      @"caption" : @{@"text" : @"texttesxttext"},
                                      @"user" : @{@"id" : @"1234567",
                                                  @"username" : @"Freckles",
                                                  @"full_name" : @"Homer Simpson",
                                                  @"profile_picture" : @"@http://www.example.com/example.jpg"}
                                      };
    Media *mediaItem = [[Media alloc] initWithDictionary:sourceDictionary];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imageName = [bundle pathForResource:[NSString stringWithFormat:@"%d", 1] ofType:@"png"];
    UIImage *image = [UIImage imageNamed:imageName];
    mediaItem.image = image;
    
    CGFloat mediaItemHeight = [MediaTableViewCell heightForMediaItem:mediaItem width:44];
    XCTAssertEqual(mediaItemHeight, 371, @"Item height should be 398");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end