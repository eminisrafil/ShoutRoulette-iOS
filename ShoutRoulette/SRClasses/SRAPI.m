//
//  SRApi.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "SRAPI.h"
#import "SRRoom.h"
#import "SRTopic.h"

@implementation SRAPI

+ (SRAPI *)sharedInstance {
	static SRAPI *sharedInstance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
	    sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kSRAPIHOST]];
	});
	return sharedInstance;
}

- (SRAPI *)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
    
	[self setReachabilityStatusChangeBlock: ^(AFNetworkReachabilityStatus status) {
	    NSLog(@"Internet Connection Status Changed: %d", status);
	}];
    
	[self setUpRestKit];
	return self;
}

- (void)setUpRestKit {
	if (self != nil) {
		//RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
		//RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
		//RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
		//RKLogConfigureByName("RestKit/Network", RKLogLevelCritical);
		//RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
		[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
		[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
		[self setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
        
		RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:self];
        
		//Topic mapping
		RKObjectMapping *topicMapping = [RKObjectMapping mappingForClass:[SRTopic class]];
		[topicMapping addAttributeMappingsFromDictionary:@{
                                                           @"id": @"topicId",
                                                           @"title" :@"title",
                                                           @"created_at" : @"createdAt",
                                                           @"disagree_debaters": @"disagreeDebaters",
                                                           @"agree_debaters" : @"agreeDebaters",
                                                           @"observers" : @"observers"
                                                           }];
        
		//setup Room mapping
		RKObjectMapping *roomMapping = [RKObjectMapping mappingForClass:[SRRoom class]];
		[roomMapping addAttributeMappingsFromDictionary:@{
                                                          @"room_id": @"roomId",
                                                          @"title" :@"title",
                                                          @"session_id": @"sessionId",
                                                          @"token": @"token",
                                                          @"created_at" : @"createdAt",
                                                          @"agree": @"agree",
                                                          @"disagree" : @"disagree",
                                                          @"error_message": @"messageMessage"
                                                          }];
        
		RKObjectMapping *roomDeleteMapping = [RKObjectMapping mappingForClass:[SRRoom class]];
		[roomMapping addAttributeMappingsFromDictionary:@{ @"message": @"message" }];
        
		RKObjectMapping *newTopicsMapping = [RKObjectMapping mappingForClass:[SRTopic class]];
		[newTopicsMapping addAttributeMappingsFromDictionary:@{ @"message":@"message" }];
        
		RKResponseDescriptor *topicResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:topicMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"Topics" statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
		RKResponseDescriptor *roomResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:roomMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"Room" statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
		RKResponseDescriptor *roomDeleteResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:roomDeleteMapping method:RKRequestMethodDELETE pathPattern:nil keyPath:@"message" statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
		RKResponseDescriptor *newTopicsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:newTopicsMapping method:RKRequestMethodPOST pathPattern:@"topics/new" keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        
		[objectManager addResponseDescriptor:topicResponseDescriptor];
		[objectManager addResponseDescriptor:newTopicsResponseDescriptor];
		[objectManager addResponseDescriptor:roomResponseDescriptor];
		[objectManager addResponseDescriptor:roomDeleteResponseDescriptor];
        
		//Routing
		//Get a Room
		[objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[SRRoom class] pathPattern:@"room/:topicId/:position" method:RKRequestMethodGET]];
		//Close a Room
		[objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[SRRoom class] pathPattern:@"room/:roomId/:position" method:RKRequestMethodDELETE]];
        
		//Pagination
		RKObjectMapping *topicPaginationMapping = [RKObjectMapping mappingForClass:[RKPaginator class]];
        
		[topicPaginationMapping addAttributeMappingsFromDictionary:@{
                                                                     @"Pagination.per_page": @"perPage",
                                                                     @"Pagination.total_pages": @"pageCount",
                                                                     @"pagination.total_objects": @"objectCount",
                                                                     }];
        
		[objectManager setPaginationMapping:topicPaginationMapping];
	}
}

@end
