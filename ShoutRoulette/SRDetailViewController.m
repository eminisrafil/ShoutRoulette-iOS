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
- (void)configureView;
@end


@implementation SRDetailViewController
@synthesize room;
static int topOffset = 0;
static int xOffset = 0;
static double opponentVidHeight = 210;
static double opponentVidWidth = 294;
static double userVidHeight = 63;
static double userVidWidth = 65;
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
    //_statusLabel = [[UILabel alloc] init];
    //_statusLabel.frame = CGRectMake(10, 380, 240, 24);
    //[self setStatusLabel];
    //[self.view addSubview:_statusLabel];

    self.room = self.detailItem;
    self.objectManager = [RKObjectManager sharedManager];
    [self.objectManager getObject:room path:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        //restkit automatically maps JSON response to Room
        NSLog(@"HERE ARE SUCCESS THE RESULTS %@", room.sessionId);
        self.detailDescriptionLabel.text = room.sessionId;
        self.kToken = room.token;
        self.kSessionId = room.sessionId;
        self.token.text = self.kToken;
        self.roomTitle.text = room.title;
        [self doConnect];
    }failure:^(RKObjectRequestOperation *operation, NSError *error){
        NSLog(@"HERE ARE SUCCESS THE RESULTS %@", error);
    }];
    

    
    [self configureView];
}

-(void)viewWillDisappear:(BOOL)animated{
    //OTPublisher
    //OTPublisherDelegate
    safeShutdown = YES;
    /*    NSLog(@"----------->>>>>>> %@", [NSString stringWithFormat:@"%@",self.parentViewController]);
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
    //[objectManager operationQueue].cancelAllOperations;
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [self._session removeObserver:self forKeyPath:@"connectionCount"];
    
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
    }
    /*    if(self._subscriber){
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
   

    
    if (_session) {
        [self doDisconnect];
    }
   */
    //put in new thread
    //[self doCloseRoomId:room.roomId position:room.position];
}

-(void)doCloseRoomId:(NSNumber *)roomId position:(NSString *)position{
    //[objectManager deleteObject:room path:nil parameters:nil success: nil failure:nil];
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - OpenTok methods

/*
- (void)createUI
{
    _connectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _connectButton.frame = CGRectMake(10, 32, 100, 44);
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [_connectButton addTarget:self
                       action:@selector(connectButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_connectButton];
    
    _disconnectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _disconnectButton.frame = CGRectMake(10, 32, 100, 44);
    [_disconnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [_disconnectButton addTarget:self
                          action:@selector(disconnectButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
    _disconnectButton.hidden = YES;
    [self.view addSubview:_disconnectButton];
    
    _publishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _publishButton.frame = CGRectMake(120, 32, 100, 44);
    [_publishButton setTitle:@"Publish" forState:UIControlStateNormal];
    [_publishButton addTarget:self
                       action:@selector(publishButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    _publishButton.hidden = YES;
    [self.view addSubview:_publishButton];
    
    _unpublishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _unpublishButton.frame = CGRectMake(120, 32, 100, 44);
    [_unpublishButton setTitle:@"Unpublish" forState:UIControlStateNormal];
    [_unpublishButton addTarget:self
                         action:@selector(unpublishButtonClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    _unpublishButton.hidden = YES;
    [self.view addSubview:_unpublishButton];
    
    _unsubscribeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _unsubscribeButton.frame = CGRectMake(10, 14 + topOffset + widgetHeight * 2, 100, 44);
    [_unsubscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
    [_unsubscribeButton addTarget:self
                           action:@selector(unsubscribeButtonClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
    _unsubscribeButton.hidden = YES;
    [self.view addSubview:_unsubscribeButton];
    
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.frame = CGRectMake(10, 400, 240, 24);
    [self setStatusLabel];
    [self.view addSubview:_statusLabel];
}

- (void)connectButtonClicked:(UIButton*)button
{
    _connectButton.hidden = YES;
    _statusLabel.text = @"Connecting...";
    [self doConnect];
}

- (void)disconnectButtonClicked:(UIButton*)button
{
    _disconnectButton.hidden = YES;
    [self doDisconnect];
}

- (void)publishButtonClicked:(UIButton*)button
{
    _publishButton.hidden = YES;
    [self doPublish];
}

- (void)unpublishButtonClicked:(UIButton*)button
{
    _unpublishButton.hidden = YES;
    [self doUnpublish];
}


- (void)unsubscribeButtonClicked:(UIButton*)button
{
    _unsubscribeButton.hidden = YES;
    [_subscriber close];
    _subscriber = nil;
}
*/


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
    [self.userVidContainer addSubview:self._publisher.view];
    [self._publisher.view setFrame:CGRectMake(xOffset, topOffset, userVidWidth, userVidHeight)];
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
    /*
    if (publisher == nil) {
        return;
    }
    if ([_publishers containsObject:publisher]) {
        [_publishers removeObject:publisher];
        [publisher close];
    } else {
        [NSException raise:@"OTException" format:@"attempt to unpublish an unknown publisher instance"];
    }*/
    
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
    //_disconnectButton.hidden = NO;
    //_connectButton.hidden = YES;
    //_publishButton.hidden = NO;
    //[self setStatusLabel];
    NSLog(@"sessionDidConnect: %@", session.sessionId);
    NSLog(@"- connectionId: %@", session.connection.connectionId);
    NSLog(@"- creationTime: %@", session.connection.creationTime);
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    //_statusLabel.text = @"Disconnected from session.";
    NSLog(@"sessionDidDisconnect: %@", session.sessionId);
   // _publishButton.hidden = YES;
   // _unpublishButton.hidden = YES;
   // _disconnectButton.hidden = YES;
    //_connectButton.hidden = NO;
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    //_connectButton.hidden = NO;
    NSLog(@"session: didFailWithError:");
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
    //_publishButton.hidden = YES;
    //_unpublishButton.hidden = YES;
    //_disconnectButton.hidden = YES;
    //_connectButton.hidden = NO;
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
    [subscriber.view setFrame:CGRectMake(xOffset, topOffset, opponentVidWidth, opponentVidHeight)];
    [self.opponentVidContainer addSubview:subscriber.view];
}

- (void)subscriberVideoDataReceived:(OTSubscriber*)subscriber {
    NSLog(@"subscriberVideoDataReceived (%@)", subscriber.stream.streamId);
    //_unsubscribeButton.hidden = NO;
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
{
    NSLog(@"subscriber: %@ didFailWithError: ", subscriber.stream.streamId);
    NSLog(@"- code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}


@end
