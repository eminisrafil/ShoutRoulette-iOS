//
//  UIView+UIView_FindUIViewController.h
//  ShoutRoulette
//
//  Created by emin on 9/25/13.
//
//  http://stackoverflow.com/a/3732812/1858229

#import <UIKit/UIKit.h>

@interface UIView (UIView_FindUIViewController)

- (UIViewController *)firstAvailableUIViewController;
- (id)traverseResponderChainForUIViewController;

@end
