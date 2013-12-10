//
//  SRTopic_Tests.m
//  ShoutRoulette
//
//  Created by emin on 12/9/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SRTopic.h"

@interface SRTopic_Tests : XCTestCase
@property SRTopic *topicA;
@property SRTopic *topicB;
@end

@implementation SRTopic_Tests

- (void)setUp {
	[super setUp];
	self.topicA = [[SRTopic alloc] init];
	self.topicB = [[SRTopic alloc] init];
}

- (void)tearDown {
	self.topicA = nil;
	self.topicB = nil;
	[super tearDown];
}

- (void)equality_test {
	XCTAssertNotNil(self.topicA, @"TopicA is Nil");
	XCTAssertNotNil(self.topicB, @"TopicB is Nil");
    
	self.topicA.topicId = @1;
	self.topicB.topicId = @2;
    
	XCTAssertNotEqualObjects(self.topicA, self.topicB, @"Topics with different id's should not be equal");
    
	self.topicB.topicId = @1;
	XCTAssertEqualObjects(self.topicA, self.topicB, @"Topics with same id's should be equal");
}

@end
