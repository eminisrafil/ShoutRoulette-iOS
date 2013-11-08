//
//  SRUrlHelper.h
//  ShoutRoulette
//
//  Created by emin on 9/27/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRUrlHelper : NSObject

+ (NSDictionary *)parseQueryString:(NSString *)query;

@end
