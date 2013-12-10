//
//  SRMasterViewController_Tests.m
//  ShoutRoulette
//
//  Created by emin on 12/9/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SRMasterViewController.h"

@interface SRMasterViewController_Tests : XCTestCase
@property SRMasterViewController *masterViewController;

@end

@implementation SRMasterViewController_Tests

- (void)setUp {
	[super setUp];
	self.masterViewController = [SRMasterViewController new];
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)notNil_test {
	XCTAssertNotNil(self.masterViewController, @"SRMasterViewController is nil");
}

- (void)paginatorSetup_test {
	XCTAssertNotNil(self.masterViewController.paginator, @"Paginator is nil");
	XCTAssertNotNil(self.masterViewController.paginator.URL, @"Paginator is nil");
}

@end
