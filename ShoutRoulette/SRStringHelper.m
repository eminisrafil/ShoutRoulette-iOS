//
//  SRStringHelper.m
//  ShoutRoulette
//
//  Created by emin on 11/6/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRStringHelper.h"

@implementation SRStringHelper

+ (NSString *)opposingPosition:(NSString *)position {
	return ([position isEqualToString:@"agree"]) ? @"disagree" : @"agree";
}

+ (NSString *)capitalizeFirstLetter:(NSString *)string {
	return [string stringByReplacingCharactersInRange:NSMakeRange(0, 1)
	                                       withString:[[string substringToIndex:1] capitalizedString]];
}

+ (NSString *)trimSessionId:(NSString *)sessionId {
	if (sessionId.length < 10) {
		return @"0";
	}
    
	NSRange range = NSMakeRange(sessionId.length - 7, 6);
	return [sessionId substringWithRange:range];
}

@end
