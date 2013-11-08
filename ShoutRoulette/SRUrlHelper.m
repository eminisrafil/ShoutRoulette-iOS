//
//  SRUrlHelper.m
//  ShoutRoulette
//
//  Created by emin on 9/27/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRUrlHelper.h"

@implementation SRUrlHelper


+ (NSDictionary *)parseQueryString:(NSString *)query {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
	for (NSString *pair in pairs) {
		NSArray *elements = [pair componentsSeparatedByString:@"="];
		NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
		[dict setObject:val forKey:key];
	}
	return dict;
}

@end
