//
//  MediaTests.m
//  Blocstagram
//
//  Created by Melissa Boring on 12/2/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Media.h"
#import "Comment.h"
#import "User.h"

@interface MediaTests : XCTestCase

@end

@implementation MediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testThatMediaInitializationWorks
{
    NSDictionary *imagesDictionary = @{@"standard_resolution" : @{@"url" : @"https://scontent.cdninstagram.com/hphotos-xpt1/t51.2885-15/s640x640/sh0.08/e35/12230874_1662426227378292_771037454_n.jpg" }};
    
    NSDictionary *captionDictionary = @{@"text" : @"texttesxttext" };
    
    NSDictionary *userDictionary = @{@"id": @"1234567",
                                     @"username" : @"d'oh",
                                     @"full_name" : @"Homer Simpson",
                                     @"profile_picture" : @"http://www.example.com/example.jpg"};
    
    NSDictionary *testUserDictionary = @{@"id": @"9999999",
                                         @"username" : @"freckles",
                                         @"full_name" : @"Jake Simpson",
                                         @"profile_picture" : @"http://www.example.com/example.jpg"};
    
    NSDictionary *testCommentDictionary = @{@"id" : @"8989898",
                                            @"text" : @"cool pic",
                                            @"from" : testUserDictionary};
    
    NSArray *commentArray = [NSArray arrayWithObjects:testCommentDictionary, nil];
    
    NSDictionary *commentsDictionary = @{@"data" : commentArray};
    
    NSDictionary *sourceDictionary = @{@"id": @"112233445",
                                       @"user" : userDictionary,
                                       @"images" : imagesDictionary,
                                       @"caption" : captionDictionary,
                                       @"comments" : commentsDictionary,
                                       @"user_has_liked" : @"0"};
    
    Media *testMedia = [[Media alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testMedia.caption, sourceDictionary[@"caption"][@"text"], @"The caption should be equal");
    
    //User
    XCTAssertEqualObjects(testMedia.user.idNumber, sourceDictionary[@"user"][@"id"], @"The user id should be equal");
    XCTAssertEqualObjects(testMedia.user.userName, sourceDictionary[@"user"][@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testMedia.user.userName, sourceDictionary[@"user"][@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testMedia.user.userName, sourceDictionary[@"user"][@"username"], @"The username should be equal");
    
    //MediaURL
    XCTAssertEqualObjects(testMedia.mediaURL.relativeString, sourceDictionary[@"images"][@"standard_resolution"][@"url"], @"The URL should be equal");
    
    //Caption
    XCTAssertEqualObjects(testMedia.caption, sourceDictionary[@"caption"][@"text"], @"The caption should be equal");
    
    //Comments
    XCTAssertTrue(testMedia.comments.count == commentArray.count);
    NSDictionary *sourceComment = [sourceDictionary[@"comments"][@"data"] objectAtIndex:0];
    Comment *testMediaComment = [testMedia.comments objectAtIndex:0];
                      
    XCTAssertEqualObjects(testMediaComment.text,sourceComment[@"text"],@"Comments should be equal");
    
}


@end