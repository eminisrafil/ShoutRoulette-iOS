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

//    NSLog(@"%@", sender);
//    NSLog(@"%ld", (long)[sender tag]);
//    UIButton *button = (UIButton *)sender;
//    //CGRect frame = CGRectMake(300, 330, 320, 30);
//
//    CGAffineTransform size = CGAffineTransformMakeScale(3, 3);
//    CGAffineTransform frame = CGAffineTransformMakeTranslation(10,-100);
//    button.transform = CGAffineTransformIdentity;
//
//    //self.statusLabel.transform = CGAffineTransformMakeScale(0.01, 0.01);
//    //self.statusLabel.transform = CGAffineTransformConcat(size, frame);
//    [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        // animate it to the identity transform (100% scale)
//        button.transform = CGAffineTransformConcat(size, frame);
//        button.alpha = 0;
//        //self.statusLabel.transform = CGAffineTransformIdentity;
//    } completion:^(BOOL finished){
//        //[SRAnimationHelper stopAnimations:self.statusLabel];
//        // if you want to do something once the animation finishes, put it here
//        button.alpha = 1;
//        button.transform = CGAffineTransformIdentity;
//    }];
