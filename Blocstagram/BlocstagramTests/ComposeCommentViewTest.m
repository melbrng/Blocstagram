//
//  ComposeCommentViewTest.m
//  Blocstagram
//
//  Created by Melissa Boring on 12/2/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ComposeCommentView.h"

@interface ComposeCommentViewTest : XCTestCase

@property(strong,nonatomic)ComposeCommentView *commentView;
@end

@implementation ComposeCommentViewTest

- (void)setUp {
    [super setUp];
    
    self.commentView = [[ComposeCommentView alloc]init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsWritingComment {
    
    [self.commentView setText:@"setting Text"];
    BOOL yesFlag =self.commentView.isWritingComment;
    
    XCTAssertTrue(yesFlag);
    
    [self.commentView setText:nil];
    BOOL noFlag =self.commentView.isWritingComment;
    
    XCTAssertTrue(noFlag == NO);
    
    
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
