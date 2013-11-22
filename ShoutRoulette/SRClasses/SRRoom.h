//
//  SRRoom.h
//  ShoutRoulette
//
//  Created by emin on 5/16/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRRoom : NSObject

@property NSString *title;
@property NSNumber *roomId;
@property NSNumber *topicId;
@property NSString *sessionId;
@property NSString *token;
@property Boolean *agree;
@property Boolean *disagree;
@property NSString *position;
@property NSString *message;
@end
