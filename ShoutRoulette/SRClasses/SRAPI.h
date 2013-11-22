//
//  SRApi.h
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "AFHTTPClient.h"
#import "RKPaginator.h"
#import <RestKit/RestKit.h>
//#import "Reachability.h"

typedef void (^JSONResponse)(NSDictionary *JSON);

@interface SRAPI : AFHTTPClient

+ (SRAPI *)sharedInstance;

@end
