//
//  SRAnimationHelper.h
//  ShoutRoulette
//
//  Created by emin on 10/4/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface SRAnimationHelper : NSObject

+ (CATransition *)tableViewReloadDataAnimation;
+ (CAAnimation *)fadeOfSRMasterViewStatusLabel;
+ (CAAnimation *)fadeOfRoomStatusLabel;
+ (CAAnimation *)fadeInOfProgressBar;
+ (void)stopAnimations:(UIView *)view;

@end
