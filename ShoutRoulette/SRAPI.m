//
//  SRApi.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRAPI.h"
#import "SRTopic.h"
#import "SRRoom.h"
#define kAPIHOST @"http://srapp.herokuapp.com/"

@implementation SRAPI
@synthesize user =  _user;


+(SRAPI*)sharedInstance
{
    static SRAPI *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        //initialize HTTPClient
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIHOST]];
    });
    return sharedInstance;
}

-(SRAPI*)initWithBaseURL:(NSURL *) url
{
    
    self = [super initWithBaseURL:url];
    
    if (self != nil) {
        _user = nil;
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
      //  RKLogConfigureByName("RestKit/Network", RKLogLevelCritical);
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        
        [self registerHTTPOperationClass: [AFJSONRequestOperation class]];
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
         //@"title" :@"title",
         @"session_id": @"sessionId",
         @"token": @"token",
         //@"created_at" : @"createdAt"
         //@"agree": @"agree",
         //@"disagree" : @"disagree"
         }];
        
        //delete a room
        RKObjectMapping *roomDeleteMapping = [RKObjectMapping mappingForClass:[SRRoom class]];
        [roomMapping addAttributeMappingsFromDictionary:@{
         @"": @"",
         }];
        
        //Response Descriptors - What to do with the JSON response block
        RKResponseDescriptor *topicResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:topicMapping pathPattern:nil keyPath:@"Topics" statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        RKResponseDescriptor *roomResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:roomMapping pathPattern:nil keyPath:@"Room" statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        RKResponseDescriptor *roomDeleteResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:roomDeleteMapping pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:204]];
        
        //Routing
        //Get a Room
        [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[SRRoom class] pathPattern:@"room/:topicId/:position" method:RKRequestMethodGET]];
        //Close a Room
        [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[SRRoom class] pathPattern:@"room/:roomId/:position" method:RKRequestMethodDELETE]];


        
        
        [objectManager addResponseDescriptor:topicResponseDescriptor];
        [objectManager addResponseDescriptor:roomResponseDescriptor];
        [objectManager addResponseDescriptor:roomDeleteResponseDescriptor];
    }
    
    return self;
}

-(BOOL)isAutherized
{
    return [[_user objectForKey:@"IdUser"] intValue] >0;
}


@end



