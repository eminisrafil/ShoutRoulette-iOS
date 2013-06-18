//
//  SRApi.h
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "AFHTTPClient.h"
#import <RestKit/RestKit.h>

typedef void(^JSONResponse)(NSDictionary* JSON);


@interface SRAPI : AFHTTPClient

@property (strong, nonatomic) NSDictionary* user;

+(SRAPI *)sharedInstance;
-(BOOL)isAutherized;
-(void)commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponse)completionBlock;



@end
