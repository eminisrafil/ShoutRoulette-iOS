//
//  SROpenTokVideoHandler.m
//  ShoutRoulette
//
//  Created by emin on 9/19/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SROpenTokVideoHandler.h"


@implementation SROpenTokVideoHandler

-(id)init{
    
    [self configOpentTokAuth];
    [self configNotifications];
    [self configStartUpOptions];
    return self;
}


#pragma mark - Register
-(void) configOpentTokAuth{
    //keys
    self.kApiKey = @"20193772"; //<--yes i know this is here.
    self.kSessionId = @"";
    self.kToken = @"";
}

-(void)configStartUpOptions
{
    //Should the user begin publising
    self.shouldPublish = YES;
    
    self.SROpentTokVideoHandlerState = 0;
    
    self.isShutDownSafe = YES;
}

-(void)configNotifications
{
    [self addObserver:self forKeyPath:@"SROpentTokVideoHandlerState" options:0 context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
{
    if([keyPath isEqualToString:@"SROpentTokVideoHandlerState"]){
        [self sendNotifications];
    }
    
}

-(void)sendNotifications
{
    NSDictionary *message = @{@"message": @(self.SROpentTokVideoHandlerState)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSROpenTokVideoHandlerNotifcations object:self userInfo:message];
}

//stream container must be set in order to publish
-(void)registerUserVideoStreamContainer:(UIView *)userVideo
{
    self.userVideoStreamConatiner = userVideo;
}

-(void) registerOpponentOneVideoStreamContainer:(UIView *)opponentOneVideo{
    self.opponentOneVideoStreamConatiner = opponentOneVideo;
}

#pragma - Connecting - Sessions
//Connect to a new room
- (void)doConnectToRoomWithSession
{
    self.SROpentTokVideoHandlerState = 1;
    self.session = [[OTSession alloc] initWithSessionId:self.kSessionId
                                                delegate:self];
    [self.session connectWithApiKey:self.kApiKey token:self.kToken];
    NSLog(@"THIS is the sessionID: %@",self.kSessionId);
}
//Connection was established
- (void)sessionDidConnect:(OTSession*)session
{
    if(self.shouldPublish){
        [self doPublish];
    }
}

#pragma - Connecting - Publishing
//Publish the users stream. (Smaller box)
- (void)doPublish
{
    if(!self.publisher.view){
        self.isShutDownSafe = NO; 

        //self.SROpentTokVideoHandlerState = publising
        self.SROpentTokVideoHandlerState = 2;
        
        NSLog(@"publishing");
        self.isPublishing = YES;

        self.publisher = [[OTPublisher alloc] initWithDelegate:self name:UIDevice.currentDevice.name];
        self.publisher.publishAudio = YES;
        self.publisher.publishVideo = YES;
        self.publisher.name = [NSString stringWithFormat:@"%@  Time:%@",[[UIDevice currentDevice] name], [NSDate date]];
        [self.session publish:self.publisher];
        
        [self.publisher.view setFrame:CGRectMake(0, 0, self.userVideoStreamConatiner.frame.size.width, self.userVideoStreamConatiner.frame.size.height)];
        self.userVideoStreamConatiner.layer.cornerRadius = 4;
        self.userVideoStreamConatiner.layer.borderWidth = 4;
        self.userVideoStreamConatiner.layer.shadowRadius = 4;
        
        //self.userScreenContainer.clipsToBounds = NO;
        //self.publisher.view.layer.shadowOffset =CGSizeMake(4, 4);
        [self.userVideoStreamConatiner addSubview:self.publisher.view];
        self.SROpentTokVideoHandlerState =3;
        
        //Shutting down within ~2 seconds of beginning to publish is prone to errors
        [self delaySafeShutdown];
    }
}

-(void)delaySafeShutdown
{
    double delayInSeconds = 2;
    NSLog(@"Shutdown is not safe");
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.isShutDownSafe = YES;
        NSLog(@"Shutdown is safe :) ");
    });
}

#pragma - Connecting - Subscribing (to Opponents)
//Session got a new stream - Gets called everytime a new video stream is posted, including the users
- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    NSLog(@"MYSESSION RECIEVED Stream name: %@",stream.name);
    if (![stream.connection.connectionId isEqualToString: self.session.connection.connectionId]) {
            NSLog(@"OPPONENT CONNECTED TO SESSION");
            NSLog(@"Connection Count: %u",self.session.connectionCount);
            [self initSubscriberWithOpponentStream:stream];
    }
}

//Subscribe to Opponent (User is both a Subscriber and a Published in a Shouting Match)
-(void)initSubscriberWithOpponentStream:(OTStream*)opponentStream
{
    self.subscriber = [[OTSubscriber alloc] initWithStream:opponentStream delegate:self];
    self.subscriber.subscribeToAudio = YES;
    self.subscriber.subscribeToVideo = YES;
    NSLog(@"INIT: SUBSCRIBING TO OPPONENTS STREAM: %@", self.subscriber);
}

//User (acting as a subscriber) connects to opponent's stream
- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    NSLog(@"CONNECTED TO SUBSCRIBER's STREAM");
    NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.connection.connectionId);
    [self addOppentStream:subscriber toContainer:self.opponentOneVideoStreamConatiner];
}

//add Opponents stream to container
//the opponents stream is in subscriber.view
-(void)addOppentStream:(OTSubscriber*)subscriber toContainer:(UIView*)view{
    self.SROpentTokVideoHandlerState =4;
    NSLog(@"ADDING OPPONENT VIDEO TO FRAME!");
    [subscriber.view setFrame:CGRectMake(0, 0, 280, 200)];
    //[subscriber.view setFrame:CGRectMake(xOffsetOpponent, topOffsetOpponent, opponentVidWidth, opponentVidHeight)];
    subscriber.view.layer.cornerRadius = 2;
    subscriber.view.layer.borderWidth = 1;
    NSLog(@"%@", view);
    NSLog(@"%@", subscriber.view);
    [view addSubview:subscriber.view];
}

#pragma - Disconnecting - Sessions
-(void)safetlyCloseSession{   
    self.SROpentTokVideoHandlerState= 6;
    NSLog(@"SHUTING DOWN!");

    //USE GRAND CENTRAL DISPATCH
    if(self.isShutDownSafe){
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//            //Background Thread
//            [self doUnpublish];
//            [self doUnsubscribe];
//            [self doDisconnect];
//            
//            dispatch_async(dispatch_get_main_queue(), ^(void){
//                //Run UI Updates
//            });
//        });
//        dispatch_queue_t myQueue = dispatch_queue_create("My Shudown Queue",NULL);
//        dispatch_async(myQueue, ^{
//            // Perform long running process
                        [self doUnpublish];
                        [self doUnsubscribe];
                        [self doDisconnect];
//            NSLog(@"shutdown queue");
//
//        });
//        
    } else {
        [self performSelector:@selector(safetlyCloseSession) withObject:nil afterDelay:2];
        NSLog(@"RETRY SHUTDOWN IN 2 seconds");
    }
}

//Unpublish user stream
- (void)doUnpublish
{
    if ([self isViewDisplayed:self.publisher.view]) {
        [self.session unpublish:self.publisher];
    } 
}

//http://stackoverflow.com/a/15251624/1858229
- (bool)isViewDisplayed:(UIView*)view
{
    if (view.window) {
        CGRect viewFrame = [view.window convertRect:view.frame fromView:view.superview];
        CGRect screenFrame = view.window.bounds;
        NSLog(@"Publisher is view displayed!");
        return CGRectIntersectsRect(viewFrame, screenFrame);
    }
    NSLog(@"Publisher NOTTTT view displayed!");
    return false;
}

-(void) doUnsubscribe{
    [self.subscriber close];
    [self.subscriber close];
    [self.subscriber close];
    [self.subscriber close];
}

/**
 * The status of this OTSession instance. Useful for ad-hoc queries about session status.
 *
 * Valid values are defined in OTSessionConnectionStatus:
 *
 * - `OTSessionConnectionStatusConnected` - The session is connected.
 * - `OTSessionConnectionStatusConnecting` - The session is connecting.
 * - `OTSessionConnectionStatusDisconnected` - The session is not connected.
 * - `OTSessionConnectionStatusFailed` - The attempt to connect to the session failed.
 *
 * On instantiation, expect the `sessionConnectionStatus` to have the value `OTSessionConnectionStatusDisconnected`.
 *
 * You can use a key-value observer to monitor this property. However, the <[OTSessionDelegate sessionDidConnect:]>
 * and <[OTSessionDelegate sessionDidDisconnect:]> messages are sent to the session's delegate when the session
 * connects and disconnects.
 */

-(bool)isDisconnected
{
    NSLog(@"Connection Status: %u",self.session.sessionConnectionStatus);
    NSLog(@"Connection Count: %u",self.session.connectionCount);
    
    //is publishing?
    if((self.session.sessionConnectionStatus == 2 || self.session.sessionConnectionStatus == 3) && self.session.connectionCount == 0){
        NSLog(@"SESSION IS ALREADY DISCONNECTED!"); 
        return true; 
    }
    return false;
    //nil if not connected
    //self.session.connection;
}

-(void)doDisconnect
{
    if([self isDisconnected]){
        //gives too many false positives
        //return;
    }
    [self.session disconnect];
    [self.session disconnect];
    [self.session disconnect];
    [self.session disconnect];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSLog(@"DELEGATE CALL: sessionDidDisconnect: %@", session.sessionId);
    NSLog(@"%@",self.session.delegate);
    NSLog(@"Connection Count: %d", self.session.connectionCount);
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream
{
    NSLog(@"session didDropStream (%@)", stream.name);
    if (![stream.connection.connectionId isEqualToString: self.session.connection.connectionId]) {
        self.SROpentTokVideoHandlerState = 5; 
    }
}


#pragma Failures
- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"session: didFailWithError:");
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error
{
    NSLog(@"publisher: %@ didFailWithError:", publisher);
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
{
    NSLog(@"subscriber: %@ didFailWithError: ", subscriber.stream.streamId);
    NSLog(@"- code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}
@end
