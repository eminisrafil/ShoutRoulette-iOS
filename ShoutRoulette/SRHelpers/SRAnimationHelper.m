//
//  SRAnimationHelper.m
//  ShoutRoulette
//
//  Created by emin on 10/4/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRAnimationHelper.h"

@implementation SRAnimationHelper

+ (CATransition *)tableViewReloadDataAnimation {
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setDuration:1];
	return animation;
}

#pragma - Refactor fadein/fadeouts
+ (CAAnimation *)fadeOfSRMasterViewStatusLabel {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.FromValue = [NSNumber numberWithFloat:0.0f];
	animation.toValue = [NSNumber numberWithFloat:1.0f];
	animation.autoreverses = YES;
	animation.BeginTime = CACurrentMediaTime() + .8;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.removedOnCompletion = NO;
	animation.duration = 2;
	return animation;
}

+ (CAAnimation *)fadeOfRoomStatusLabel {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.FromValue = [NSNumber numberWithFloat:0.2f];
	animation.toValue = [NSNumber numberWithFloat:1.0f];
	animation.autoreverses = YES;
	animation.removedOnCompletion = NO;
	animation.duration = 1;
	animation.repeatCount = 99;
	return animation;
}

+ (CAAnimation *)fadeInOfProgressBar {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.FromValue = [NSNumber numberWithFloat:0.0f];
	animation.toValue = [NSNumber numberWithFloat:1.0f];
	animation.autoreverses = NO;
	//keep?
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.removedOnCompletion = YES;
	animation.duration = 3;
	return animation;
}

+ (void)stopAnimations:(UIView *)view {
	[view.layer removeAllAnimations];
}

@end
