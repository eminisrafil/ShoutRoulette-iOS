//
//  SRTopic.h
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRTopic : NSObject

@property NSString *title;
@property NSNumber *topicId;
@property NSNumber *agreeDebaters;
@property NSNumber *disagreeDebaters;
@property NSNumber *observers;
@property NSNumber *total; 
@property NSString *createdAt;

@end
