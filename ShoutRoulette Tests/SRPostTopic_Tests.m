//
//  SRPostTopic_Tests.m
//  ShoutRoulette
//
//  Created by emin on 12/9/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SRPostTopic.h"


@interface SRPostTopic_Tests : XCTestCase <SRPostTopicDelegate>
@property SRPostTopic *postTopic;
@property NSString *textViewContent;
@end

@implementation SRPostTopic_Tests

- (void)setUp {
	[super setUp];
	self.postTopic = [[SRPostTopic alloc]initWithFrame:CGRectMake(0, 0, 320, 133)];
	self.postTopic.delegate = self;
}

- (void)tearDown {
	self.postTopic = nil;
	self.textViewContent = nil;
	[super tearDown];
}

- (void)testNotNil_test {
	XCTAssertNotNil(self.postTopic, @"Posttopic is nil");
}

- (void)returnValidPost_test {
	NSString *message = @"This is a valid post.";
	self.postTopic.textView.text = message;
	[self.postTopic post:nil];
    
	BOOL isEqual = [message isEqualToString:self.textViewContent];
    
	XCTAssertTrue(isEqual, @"Message(%@) typed into TextView doest not equal message returned to delegate(%@)", message, self.textViewContent);
}

- (void)returnInvalidPost_test {
	NSString *message = @":(";
	self.postTopic.textView.text = message;
	[self.postTopic post:nil];
    
	BOOL isEqual = [message isEqualToString:self.textViewContent];
    
	XCTAssertFalse(isEqual, @"Message(%@) typed into TextView doest not equal message returned to delegate(%@)", message, self.textViewContent);
}

- (void)postTopicButtonPressed:(NSString *)contents {
	self.textViewContent = contents;
}

@end
