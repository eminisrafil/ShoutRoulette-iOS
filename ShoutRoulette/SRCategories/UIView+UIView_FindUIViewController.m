//
//  UIView+UIView_FindUIViewController.m
//  ShoutRoulette
//


#import "UIView+UIView_FindUIViewController.h"

//http://stackoverflow.com/a/3732812/1858229
@implementation UIView (UIView_FindUIViewController)

- (UIViewController *)firstAvailableUIViewController {
	// convenience function for casting and to "mask" the recursive function
	return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id)traverseResponderChainForUIViewController {
	id nextResponder = [self nextResponder];
	if ([nextResponder isKindOfClass:[UIViewController class]]) {
		return nextResponder;
	}
	else if ([nextResponder isKindOfClass:[UIView class]]) {
		return [nextResponder traverseResponderChainForUIViewController];
	}
	else {
		return nil;
	}
}

@end
