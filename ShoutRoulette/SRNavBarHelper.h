//
//  SRNavBarHelper.h
//  ShoutRoulette
//
//  Created by emin on 10/23/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRNavBarHelper : NSObject

+ (UIBarButtonItem *)buttonForNavBarWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage selector:(SEL)sel target:(NSObject *)target;

+ (UIBarButtonItem *)activityIndicatorNavButton;
@end
