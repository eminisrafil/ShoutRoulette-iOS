//
//  SRNavBarHelper.m
//  ShoutRoulette
//
//  Created by emin on 10/23/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRNavBarHelper.h"

@implementation SRNavBarHelper


+ (UIBarButtonItem *)buttonForNavBarWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage selector:(SEL)sel target:(NSObject *)target {
	CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:frame];
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    
	if (highlightedImage) {
		[button setImage:highlightedImage forState:UIControlStateHighlighted];
	}
    
	UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	return navButton;
}

+ (UIBarButtonItem *)activityIndicatorNavButton {
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(7, 0, 20, 20)];
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator startAnimating];
	return barButton;
}

@end
