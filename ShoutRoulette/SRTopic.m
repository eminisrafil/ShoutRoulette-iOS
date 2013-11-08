//
//  SRTopic.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRTopic.h"

@implementation SRTopic


- (BOOL)isEqual:(id)object {
	if (![object isKindOfClass:[SRTopic class]]) {
		return NO;
	}
    
	SRTopic *other = (SRTopic *)object;
	return [other.topicId intValue] == [self.topicId intValue];
}

@end
