//
//  SRApi.h
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "AFHTTPClient.h"
#import <RestKit/RestKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "SRTopic.h"
#import "SRRoom.h"
//#import "Reachability.h"

typedef void(^JSONResponse)(NSDictionary* JSON);


@interface SRAPI : AFHTTPClient

@property (strong, nonatomic) NSDictionary* user;

+(SRAPI *)sharedInstance;


@end
