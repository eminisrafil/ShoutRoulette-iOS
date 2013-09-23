//
//  SROpenTokVideoHandler.h
//  ShoutRoulette
//
//  Created by emin on 9/19/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Opentok/Opentok.h>

@interface SROpenTokVideoHandler : NSObject <OTPublisherDelegate, OTSessionDelegate, OTSubscriberDelegate>

@property (strong, nonatomic) NSString* kApiKey;
@property (strong, nonatomic) NSString* kSessionId;
@property (strong, nonatomic) NSString* kToken;


@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) OTPublisher* publisher;
@property (strong, nonatomic) OTSubscriber* subscriber;

@property (strong, nonatomic) UIView* userVideoStreamConatiner;
@property (strong, nonatomic) UIView* opponentOneVideoStreamConatiner;

typedef enum {
    disconnected = 0,
    connecting = 1, 
    publishing = 2,
    searchingForOpponent = 3,
    connectedToOpponent = 4,
    opponentDisconnected = 5,
    disconnecting = 6
} SROpenTokVideoHandlerState;

@property SROpenTokVideoHandlerState SROpentTokVideoHandlerState; 


//default = YES
@property BOOL shouldPublish;
@property bool isPublishing;
@property bool isShutDownSafe;
- (void)doConnectToRoomWithSession;
- (void)registerUserVideoStreamContainer:(UIView *) userVideo;
- (void)registerOpponentOneVideoStreamContainer:(UIView *) opponentOneVideo;
- (void)safetlyCloseSession;


@end
