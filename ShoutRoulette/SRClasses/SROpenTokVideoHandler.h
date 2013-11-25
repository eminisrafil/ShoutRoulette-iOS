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

@property (strong, nonatomic) NSString *kApiKey;
@property (strong, nonatomic) NSString *kSessionId;
@property (strong, nonatomic) NSString *kToken;

@property (strong, nonatomic) OTSession *session;
@property (strong, nonatomic) OTPublisher *publisher;
@property (strong, nonatomic) OTSubscriber *subscriber;
@property (strong, nonatomic) OTSubscriber *subscriber2;

@property (strong, nonatomic) UIView *userVideoStreamConatiner;
@property (strong, nonatomic) NSString *userVideoStreamName;
@property (strong, nonatomic) UIView *opponentOneVideoStreamConatiner;
@property (strong, nonatomic) NSString *opponentOneVideoStreamName;

typedef NS_ENUM(NSInteger, SROpenTokVideoHandlerState){
	SROpenTokStateDisconnected = 0,
	SROpenTokStateConnecting = 1,
	SROpenTokStatePublishing = 2,
	SROpenTokStateSearchingForOpponent = 3,
	SROpenTokStateConnectedToOpponent = 4,
	SROpenTokStateOpponentDisconnected = 5,
	SROpenTokStateDisconnecting = 6,
	SROpenTokStateFailure = 7,
	SROpenTokStateTwoIncomingStreams = 88, //for observers
	SROpenTokStateAllPublishersDisconnected = 99 //for observers
};


@property SROpenTokVideoHandlerState SROpentTokVideoHandlerState;

//default = YES
@property BOOL shouldPublish;
@property BOOL isPublishing;
@property BOOL isShutDownSafe;

//default =NO
@property BOOL isObserving;

//apikeys, token and session be passed appropriate values before connecting to a room/session
- (void)doConnectToRoomWithSession;
- (void)registerUserVideoStreamContainer:(UIView *)userVideo;
- (void)registerOpponentOneVideoStreamContainer:(UIView *)opponentOneVideo;
- (void)safetlyCloseSession;

@end
