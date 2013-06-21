//
//  SRDetailViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRDetailViewController.h"


@interface SRDetailViewController (){
    BOOL safeShutdown;    
    //UIButton* _connectButton;
    //UIButton* _disconnectButton;
    //UIButton* _publishButton;
    //UIButton* _unpublishButton;
    //UIButton* _unsubscribeButton;
    //UILabel* _statusLabel;
}
@end

@implementation SRDetailViewController
@synthesize room;
static int topOffsetUser = 3;
static int xOffsetUser = 4;
static int topOffsetOpponent = 6;
static int xOffsetOpponent = 7;
static double opponentVidHeight = 220;
static double opponentVidWidth = 300;
static double userVidHeight = 86;
static double userVidWidth = 87;
static bool subscribeToSelf = NO;

//static NSString* const kApiKey = @"20193772";    // Replace with your API Key
//static NSString* kSessionId = @""; // Replace with your generated Session ID
//static NSString* kToken = @"";     // Replace with your generated Token (use Project Tools or from a server-side library)

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    
    self.opponentVidContainer.layer.cornerRadius = 8;
    self.opponentVidContainer.layer.borderColor = [UIColor redColor].CGColor;
    self.userVidContainer.layer.cornerRadius = 8;
    self.userVidContainer.layer.borderColor = [UIColor redColor].CGColor;
    self.opponentVidContainer.layer.borderWidth = 2;
    if (self.detailItem) {
    }
}
-(void)viewWillAppear:(BOOL)animated{
    self._subscriber = nil;
    self._session = nil;
    self._publisher= nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    safeShutdown = YES;
    self.kApiKey = @"20193772";    // Replace with your API Key
    self.kSessionId = @""; // Replace with your generated Session ID
    self.kToken = @"";
    
    [self performGetRoomRequest];

}
-(void)performGetRoomRequest{
    self.room = self.detailItem;
    self.objectManager = [RKObjectManager sharedManager];
    [self.objectManager getObject:room path:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        //restkit automatically maps JSON response to Room
        self.detailDescriptionLabel.text = room.sessionId;
        self.kToken = room.token;
        self.kSessionId = room.sessionId;
        self.token.text = self.kToken;
        self.roomTitle.text = room.title;
        [self doConnect];
    }failure:^(RKObjectRequestOperation *operation, NSError *error){
        NSLog(@"HERE ARE SUCCESS THE RESULTS %@", error);
    }];
}

-(void)viewWillDisappear:(BOOL)animated{    
    /*  
     NSLog(@"----------->>>>>>> %@", [NSString stringWithFormat:@"%@",self.parentViewController]);
    NSLog(@"----------->>>>>>> %@", [NSString stringWithFormat:@"%u", self._session.sessionConnectionStatus]);
    NSLog(@"----------->>>>>>> A");
    if(self._subscriber){
        [self._subscriber close];
        self._subscriber = nil;
    }
    NSLog(@"----------->>>>>>> B");
    if (self._publisher) {
        [self doUnpublish];
    }
    
    NSLog(@"----------->>>>>>> C");
    if (self._session) {
        [self._session disconnect];
        self._session=nil;
    }
    NSLog(@"----------->>>>>>> D");
     */
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];

}

-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"----------->>>>>>> %@", [NSString stringWithFormat:@"%u", self._session.sessionConnectionStatus]);
    NSLog(@"----------->>>>>>> A");
    
    safeShutdown = YES;
    [self._session removeObserver:self forKeyPath:@"connectionCount"];
    
    if(self._subscriber){
        [self._subscriber close];
        self._subscriber = nil;
    }
    if (self._publisher) {
        [self doUnpublish];
    }
    
    if (self._session) {
        [self._session disconnect];
        self._session=nil;
    }
    
    [self._session setDelegate:nil];
    [self._publisher setDelegate:nil];
    [self._subscriber setDelegate:nil];
    
    [self doCloseRoomId:room.roomId position:room.position];
}

-(void)doCloseRoomId:(NSNumber *)roomId position:(NSString *)position{
    [self.objectManager deleteObject:room path:nil parameters:nil success: nil failure:nil];
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];

    [self dismissViewControllerAnimated:YES completion:nil];
    // Dispose of any resources that can be recreated.
}

#pragma mark - OpenTok methods


- (void)updateSubscriber
{
    for (NSString* streamId in self._session.streams) {
        OTStream* stream = [self._session.streams valueForKey:streamId];
        if (stream.connection.connectionId != self._session.connection.connectionId) {
            self._subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            break;
        }
    }
}

#pragma mark - OpenTok methods

- (void)doConnect
{
    safeShutdown = NO;
    self._session = [[OTSession alloc] initWithSessionId:self.kSessionId
                                           delegate:self];
    [self._session addObserver:self
               forKeyPath:@"connectionCount"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    [self._session connectWithApiKey:self.kApiKey token:self.kToken];
}

- (void)doDisconnect
{
    [self._session disconnect];
}

- (void)doPublish
{
    self._publisher = [[OTPublisher alloc] initWithDelegate:self name:UIDevice.currentDevice.name];
    self._publisher.publishAudio = YES;
    self._publisher.publishVideo = YES;
    [self._session publish:self._publisher];
    
    [self._publisher.view setFrame:CGRectMake(xOffsetUser, topOffsetUser, userVidWidth, userVidHeight)];
    self._publisher.view.layer.cornerRadius = 2;
    self._publisher.view.layer.borderWidth = 1;
    [self.userScreenContainer addSubview:self._publisher.view];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    NSLog(@"KO-----------}}}}}>>>>>>> %@", [NSString stringWithFormat:@"%u", self._session.sessionConnectionStatus]);
    NSLog(@"Session id-----------}}}}}>>>>>>> %@", [NSString stringWithFormat:@"%@", self._session.sessionId]);
    if (safeShutdown) {
        NSLog(@"SAFETLY SHUTTING DOWN-----------}}}}}>>>>>>> %@", [NSString stringWithFormat:@"%u", self._session.sessionConnectionStatus]);
       /* [self._session removeObserver:self forKeyPath:@"connectionCount"];
        object = nil;
        [self._session setDelegate:nil];
        [self._publisher setDelegate:nil];
        [self._subscriber setDelegate:nil];
        if(self._subscriber){
            [self._subscriber close];
            self._subscriber = nil;
        }
        if (self._publisher) {
            [self doUnpublish];
        }
        
        if (self._session) {
            [self._session disconnect];
            self._session=nil;
        }*/
        NSLog(@"<<<<  KO SHUT DOWN-----------}}}}}>>>>>>>");
    }

    //if ([keyPath isEqualToString:@"connectionCount"]) {
       // [self setStatusLabel];
    //}
}


- (void)doUnpublish
{

    [self._session unpublish:self._publisher];
    self._publisher = nil;
    
}

- (void)setStatusLabel
{
   /* if (_session && _session.connectionCount > 0) {
        _statusLabel.text = [NSString stringWithFormat:@"Connections: %d Streams: %d", _session.connectionCount, _session.streams.count];
    } else {
        _statusLabel.text = @"Not connected.";
    }*/
}

#pragma mark - OTSessionDelegate methods

- (void)sessionDidConnect:(OTSession*)session
{
    [self doPublish];
    NSLog(@"sessionDidConnect: %@", session.sessionId);
    NSLog(@"- connectionId: %@", session.connection.connectionId);
    NSLog(@"- creationTime: %@", session.connection.creationTime);
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSLog(@"sessionDidDisconnect: %@", session.sessionId);
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"session: didFailWithError:");
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}

- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    //[self setStatusLabel];
    NSLog(@"session: didReceiveStream:");
    NSLog(@"- connection.connectionId: %@", stream.connection.connectionId);
    NSLog(@"- connection.creationTime: %@", stream.connection.creationTime);
    NSLog(@"- session.sessionId: %@", stream.session.sessionId);
    NSLog(@"- streamId: %@", stream.streamId);
    NSLog(@"- type %@", stream.type);
    NSLog(@"- creationTime %@", stream.creationTime);
    NSLog(@"- name %@", stream.name);
    NSLog(@"- hasAudio %@", (stream.hasAudio ? @"YES" : @"NO"));
    NSLog(@"- hasVideo %@", (stream.hasVideo ? @"YES" : @"NO"));
    if ( (subscribeToSelf && [stream.connection.connectionId isEqualToString: self._session.connection.connectionId])
        ||
        (!subscribeToSelf && ![stream.connection.connectionId isEqualToString: self._session.connection.connectionId])
        ) {
        if (!self._subscriber) {
            self._subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            self._subscriber.subscribeToAudio = YES;
            self._subscriber.subscribeToVideo = YES;
        }
        NSLog(@"subscriber.session.sessionId: %@", self._subscriber.session.sessionId);
       // NSLog(@"- stream.streamId: %@", _subscriber.stream.streamId);
        //NSLog(@"- subscribeToAudio %@", (_subscriber.subscribeToAudio ? @"YES" : @"NO"));
       // NSLog(@"- subscribeToVideo %@", (_subscriber.subscribeToVideo ? @"YES" : @"NO"));
    }
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream
{
    //[self setStatusLabel];
    NSLog(@"session didDropStream (%@)", stream.streamId);
    if (!subscribeToSelf
        && self._subscriber
        && [self._subscriber.stream.streamId isEqualToString: stream.streamId]) {
        self._subscriber = nil;
        //_unsubscribeButton.hidden = YES;
        [self updateSubscriber];
    }
}

#pragma mark - OTPublisherDelegate methods

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error
{
    NSLog(@"publisher: %@ didFailWithError:", publisher);
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}

- (void)publisherDidStartStreaming:(OTPublisher *)publisher
{
    //_unpublishButton.hidden = NO;
    NSLog(@"publisherDidStartStreaming: %@", publisher);
    NSLog(@"- publisher.session: %@", publisher.session.sessionId);
    NSLog(@"- publisher.name: %@", publisher.name);
}

-(void)publisherDidStopStreaming:(OTPublisher*)publisher
{
    //self._publishButton.hidden = NO;
    NSLog(@"publisherDidStopStreaming:%@", publisher);
}

#pragma mark - OTSubscriberDelegate methods

- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.connection.connectionId);
    [subscriber.view setFrame:CGRectMake(xOffsetOpponent, topOffsetOpponent, opponentVidWidth, opponentVidHeight)];
    subscriber.view.layer.cornerRadius = 2;
    subscriber.view.layer.borderWidth = 1;
    [self.opponentScreenContainer addSubview:subscriber.view];
}

- (void)subscriberVideoDataReceived:(OTSubscriber*)subscriber {
    NSLog(@"subscriberVideoDataReceived (%@)", subscriber.stream.streamId);
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
{
    NSLog(@"subscriber: %@ didFailWithError: ", subscriber.stream.streamId);
    NSLog(@"- code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}


@end
