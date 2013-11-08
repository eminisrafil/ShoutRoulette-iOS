//
//  SRStringHelper.h
//  ShoutRoulette
//
//  Created by emin on 11/6/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRStringHelper : NSObject

+ (NSString *)opposingPosition:(NSString *)position;
+ (NSString *)capitalizeFirstLetter:(NSString *)string;
+ (NSString *)trimSessionId:(NSString *)sessionId;

@end
