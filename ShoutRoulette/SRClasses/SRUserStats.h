//
//  SRUserStats.h
//  ShoutRoulette
//
//  Created by emin on 11/25/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRUserStats : NSObject

-(NSNumber *)getUsageStat:(NSString *)stat;
-(void)incrementStat:(NSString *)stat;
-(void)displayUserInstallationMessage;
-(void)displayFirstMatchMessage;
-(void)displayFirstObserveMessage;
@end
