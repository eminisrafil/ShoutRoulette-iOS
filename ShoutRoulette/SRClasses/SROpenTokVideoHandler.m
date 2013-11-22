//
//  SROpenTokVideoHandler.m
//  ShoutRoulette
//
//  Created by emin on 9/19/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SROpenTokVideoHandler.h"

@implementation SROpenTokVideoHandler

- (id)init {
	[self configOpentTokAuth];
	[self configNotifications];
	[self configStartUpOptions];
	return self;
}

#pragma mark - Register
- (void)configOpentTokAuth {
	self.kApiKey = kSROpentTokAPIKey;
	self.kSessionId = @"";
	self.kToken = @"";
}

- (void)configStartUpOptions {
	//Should the user begin publising immediately after connecting to session
	self.shouldPublish = YES;

	self.SROpentTokVideoHandlerState = SROpenTokStateDisconnected;
    
	self.isShutDownSafe = YES;
	self.isObserving = NO;
}

- (void)configNotifications {
	[self addObserver:self forKeyPath:kSROpentTokVideoHandlerStateObserver options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kSROpentTokVideoHandlerStateObserver]) {
		[self sendNotifications];
	}
}

- (void)sendNotifications {
	NSDictionary *message = @{ @"message": @(self.SROpentTokVideoHandlerState) };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kSROpenTokVideoHandlerNotifcations object:self userInfo:message];
}

//stream container must be set in order to publish
- (void)registerUserVideoStreamContainer:(UIView *)userVideo {
	self.userVideoStreamConatiner = nil;
	self.userVideoStreamConatiner = userVideo;
}

- (void)registerOpponentOneVideoStreamContainer:(UIView *)opponentOneVideo {
	self.opponentOneVideoStreamConatiner = nil;
	self.opponentOneVideoStreamConatiner = opponentOneVideo;
}

#pragma - Connecting - Sessions
- (void)doConnectToRoomWithSession {
	self.SROpentTokVideoHandlerState = SROpenTokStateConnecting;
    
	self.session = nil;
	self.subscriber = nil;
	self.subscriber2 = nil;
	self.publisher = nil;
    
	self.session = [[OTSession alloc] initWithSessionId:self.kSessionId
	                                           delegate:self];
	[self.session connectWithApiKey:self.kApiKey token:self.kToken];
    
	//NSLog(@"This is the sessionID: %@", self.kSessionId);
}

//Connection was established
- (void)sessionDidConnect:(OTSession *)session {
	if (self.shouldPublish) {
        dispatch_queue_t publishQueue = dispatch_queue_create("Emin's Publishers Queue", NULL);
        dispatch_async(publishQueue, ^{
            [self doPublish];
        });
        
		//[self doPublish];
	}
	else {
		self.SROpentTokVideoHandlerState = SROpenTokStateSearchingForOpponent;
	}
}

#pragma - Connecting - Publishing
//Publish the users stream. (Smaller box)
- (void)doPublish {
	self.isShutDownSafe = NO;
    
	self.SROpentTokVideoHandlerState = SROpenTokStatePublishing;
	if (!self.publisher.view) {
		self.isPublishing = YES;
		NSString *publisherName = [NSString stringWithFormat:@"%@", self.userVideoStreamName];
        __weak typeof(self) weakSelf = self;
		self.publisher = [[OTPublisher alloc] initWithDelegate:weakSelf name:publisherName];
		self.publisher.publishAudio = YES;
		self.publisher.publishVideo = NO;
        
        [self.session publish:self.publisher];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addPublishersVideoToView:self.userVideoStreamConatiner];
        });
        
		self.SROpentTokVideoHandlerState = SROpenTokStateSearchingForOpponent;
        
		//Shutting down within ~2 seconds of beginning to publish is prone to errors
		[self delaySafeShutdown];
	}
}

- (void)addPublishersVideoToView:(UIView *)view {
	[self.publisher.view setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
	view.layer.cornerRadius = 4;
	view.layer.borderWidth = 3;
	[view addSubview:self.publisher.view];
}

- (void)delaySafeShutdown {
	double delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
	    self.isShutDownSafe = YES;
	});
}

#pragma - Connecting - Subscribing (to Opponents)
//Session got a new stream - Gets called everytime a new video stream is posted, including the users
- (void)session:(OTSession *)mySession didReceiveStream:(OTStream *)stream {
	//NSLog(@"MYSESSION RECIEVED NAMED:(%@) Connection Count: %u ", stream.name, self.session.connectionCount);
	NSString *streamName = [NSString stringWithFormat:@"%@", stream.name];
    
	if (self.isObserving) {
		if ([streamName isEqualToString:@"agree"]) {
			[self initSubscriber:self.subscriber WithOpponentStream:stream];
		}
		else {
			[self initSubscriber:self.subscriber2 WithOpponentStream:stream];
		}
	}
    
	if (![stream.connection.connectionId isEqualToString:self.session.connection.connectionId] && !self.isObserving) {
		[self initSubscriber:self.subscriber WithOpponentStream:stream];
	}

}

//Subscribe to Opponent (User is both a Subscriber and a Published in a Shouting Match)
- (void)initSubscriber:(OTSubscriber *)subscriber WithOpponentStream:(OTStream *)opponentStream {
	subscriber = [[OTSubscriber alloc] initWithStream:opponentStream delegate:self];
	subscriber.subscribeToAudio = YES;
	subscriber.subscribeToVideo = NO;
}

//User (acting as a subscriber) connects to opponent's stream
- (void)subscriberDidConnectToStream:(OTSubscriber *)subscriber {
	//NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.name);
	if ([subscriber.stream.name isEqualToString:@"agree"] && self.isObserving) {
		[self addOppentStream:subscriber toContainer:self.userVideoStreamConatiner];
	}
	else {
		[self addOppentStream:subscriber toContainer:self.opponentOneVideoStreamConatiner];
	}
}

- (void)addOppentStream:(OTSubscriber *)subscriber toContainer:(UIView *)view {
	[subscriber.view setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
	view.layer.cornerRadius = 3;
	view.layer.borderWidth = 3;
    
	[view addSubview:subscriber.view];
    
    //added after
    [self connectedToOpponentRoomUpdate];
}

//Moment when videos first synchronize
//- (void)subscriberVideoDataReceived:(OTSubscriber *)subscriber {
//    [self connectedToOpponent];
//}

-(void)connectedToOpponentRoomUpdate {
	self.SROpentTokVideoHandlerState = SROpenTokStateConnectedToOpponent;
    
	if (self.isObserving) {
		if ((int)[self.session.streams count] == 2) {
			self.SROpentTokVideoHandlerState = SROpenTokStateTwoIncomingStreams;
		}
	}
}

#pragma - Disconnecting - Sessions
- (void)safetlyCloseSession {
	self.SROpentTokVideoHandlerState = SROpenTokStateDisconnecting;
    
	if (self.isShutDownSafe) {
		[self doUnpublish];
		[self doUnsubscribe];
		[self doDisconnect];
	}
	else {
		[self performSelector:@selector(safetlyCloseSession) withObject:nil afterDelay:2];
	}
}

//Unpublish user stream --Nil out containers?
- (void)doUnpublish {
	if ([self isViewDisplayed:self.publisher.view]) {
		[self.session unpublish:self.publisher];
		for (UIView *view in self.userVideoStreamConatiner.subviews) {
			[view.layer removeAllAnimations];
			//uncomment to remove entire container
			//[view removeFromSuperview];
		}
	}
	self.userVideoStreamConatiner.layer.borderWidth = 0;
	self.userVideoStreamConatiner = nil;
	self.userVideoStreamName = nil;
}

//http://stackoverflow.com/a/15251624/1858229
- (BOOL)isViewDisplayed:(UIView *)view {
	if (view.window) {
		CGRect viewFrame = [view.window convertRect:view.frame fromView:view.superview];
		CGRect screenFrame = view.window.bounds;
		return CGRectIntersectsRect(viewFrame, screenFrame);
	}
	return false;
}
//sorry about repeat method calls, it seems to work better with OpentokAPI
- (void)doUnsubscribe {
	[self.subscriber close];
	[self.subscriber close];
	if (self.subscriber2) {
		[self.subscriber2 close];
		[self.subscriber2 close];
		self.userVideoStreamConatiner.layer.borderWidth = 0;
		self.userVideoStreamConatiner = nil;
	}
	self.opponentOneVideoStreamConatiner.layer.borderWidth = 0;
	self.opponentOneVideoStreamConatiner = nil;
	self.opponentOneVideoStreamName = nil;
}

- (void)doDisconnect {
	[self.session disconnect];
	[self.session disconnect];
}

- (void)sessionDidDisconnect:(OTSession *)session {
	self.SROpentTokVideoHandlerState = SROpenTokStateDisconnected;
    
	//NSLog(@"sessionDidDisconnect: %@", session.stream.name);
}

- (void)session:(OTSession *)session didDropStream:(OTStream *)stream {
	//NSLog(@"session didDropStream (%@)", stream.name);
	if (![stream.connection.connectionId isEqualToString:self.session.connection.connectionId] && !self.isObserving) {
		self.opponentOneVideoStreamConatiner.layer.borderWidth = 0;
		self.SROpentTokVideoHandlerState = SROpenTokStateOpponentDisconnected;
	}
    
	//refactor/check this
	if (self.isObserving) {
		switch ([session.streams count]) {
			case 0:
				self.SROpentTokVideoHandlerState = SROpenTokStateAllPublishersDisconnected;
				break;
                
			case 1:
				self.SROpentTokVideoHandlerState = SROpenTokStateConnectedToOpponent;
                
			case 2:
				self.SROpentTokVideoHandlerState = SROpenTokStateTwoIncomingStreams;
                
			default:
				break;
		}
	}
}

#pragma Failures
- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
	self.SROpentTokVideoHandlerState = SROpenTokStateFailure;
    
//	NSLog(@"session:%@ didFailWithError:", session);
//	NSLog(@"- error code: %d", error.code);
//	NSLog(@"- description: %@", error.localizedDescription);
}

- (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error {
	self.SROpentTokVideoHandlerState = SROpenTokStateFailure;
    
//	NSLog(@"publisher: %@ didFailWithError:", publisher);
//	NSLog(@"- error code: %d", error.code);
//	NSLog(@"- description: %@", error.localizedDescription);
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error {
	self.SROpentTokVideoHandlerState = SROpenTokStateFailure;
    
//	NSLog(@"subscriber: %@ didFailWithError: ", subscriber.stream.streamId);
//	NSLog(@"- code: %d", error.code);
//	NSLog(@"- description: %@", error.localizedDescription);
}

@end
