//
//  SRNoResultsViewController.m
//  ShoutRoulette
//
//  Created by emin on 8/30/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRNoResultsViewController.h"
#import "SVPullToRefresh.h"
#import <QuartzCore/QuartzCore.h>
#import <TestFlight.h>

@implementation SRNoResultsViewController


- (void)viewDidLoad {
	[super viewDidLoad];
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
	[self configureScrollViewContainer];
	[self addCenteredImageTo:self.containerScrollView];
	[TestFlight passCheckpoint:@"No-Results-ViewController"];
}

- (void)configureScrollViewContainer {
	self.containerScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (self.view.frame.size.height * 1.20));
    
	__weak SRNoResultsViewController *weakSelf = self;
	[self.containerScrollView addPullToRefreshWithActionHandler: ^(void) {
	    [weakSelf performSelector:@selector(refresh) withObject:nil afterDelay:1.2];
	}];
    
	[self.containerScrollView.pullToRefreshView setArrowColor:[UIColor whiteColor]];
}

- (void)addCenteredImageTo:(UIView *)view {
	UIImageView *noResultsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noInternet.png"]];
    
	noResultsImageView.frame = CGRectOffset(noResultsImageView.frame, (self.view.frame.size.width -  noResultsImageView.frame.size.width) / 2, (self.view.frame.size.height -  noResultsImageView.frame.size.height) / 2);
    
	[view addSubview:noResultsImageView];
}

- (void)refresh {
	[self dismissViewControllerAnimated:YES completion: ^{
	    [[NSNotificationCenter defaultCenter] postNotificationName:kSRFetchNewTopicsAndReloadTableData object:nil];
	}];
}

@end
