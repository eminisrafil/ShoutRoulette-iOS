//
//  SRDetailViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRDetailViewController.h"

static int topOffsetUser = 3;
static int xOffsetUser = 4;
static int topOffsetOpponent = 6;
static int xOffsetOpponent = 7;
static double opponentVidHeight = 220;
static double opponentVidWidth = 300;
static double userVidHeight = 86;
static double userVidWidth = 87;
static bool subscribeToSelf = NO;

@interface SRDetailViewController ()

@property (strong, nonatomic) NSString* kApiKey;
@property (strong, nonatomic) NSString* kSessionId;
@property (strong, nonatomic) NSString* kToken;

@end

@implementation SRDetailViewController

//set to nil just incase
-(void)viewWillAppear:(BOOL)animated{
    self.subscriber = nil;
    self.session = nil;
    self.publisher= nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.kApiKey = @"20193772"; //<--yes i know this is here. 
    self.kSessionId = @""; 
    self.kToken = @"";
    
    self.opentokQueue = dispatch_queue_create("OPentTokStopCrashingPlease", NULL);
    [self performGetRoomRequest];

}
-(void)performGetRoomRequest{
    [[RKObjectManager sharedManager] getObject:self.room
                                          path:nil
                                    parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
            self.kToken = self.room.token;
            self.kSessionId = self.room.sessionId;
            self.roomTitle.text = self.room.title;
            [self doConnect];
        }failure:^(RKObjectRequestOperation *operation, NSError *error){
            NSLog(@"HERE ARE SUCCESS THE RESULTS %@", error);
    }];
}

-(void)viewWillDisappear:(BOOL)animated{    
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
}

-(void)viewDidDisappear:(BOOL)animated{

    //dispatch_async(self.opentokQueue, ^{
    [self.session removeObserver:self forKeyPath:@"connectionCount"];
    if(self.subscriber){
        [self.subscriber close];
        self.subscriber = nil;
    }
    if (self.publisher) {
        [self doUnpublish];
    }
    
    if (self.session) {
        [self.session disconnect];
        self.session=nil;
    }
    //});
    [self doCloseRoomId:self.room.roomId position:self.room.position];
}

-(void)doCloseRoomId:(NSNumber *)roomId position:(NSString *)position{
    [[RKObjectManager sharedManager] deleteObject:self.room
                                             path:nil
                                       parameters:nil
                                          success:nil
                                          failure:nil
     ];
}


//listen for connection changes to update status label
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"connectionCount"]) {
        [self setStatusLabel];
    }
}

- (void)setStatusLabel
{
    if (self.session && self.session.connectionCount == 1) {
     //self.statusLabel.text = [NSString stringWithFormat:@"Connections: %d Streams: %d", _session.connectionCount, _session.streams.count];
        self.statusLabel.text = @"Connected";
    }
    
    
}

#pragma mark - OpenTok methods
- (void)updateSubscriber
{
    for (NSString* streamId in self.session.streams) {
        OTStream* stream = [self.session.streams valueForKey:streamId];
        if (stream.connection.connectionId != self.session.connection.connectionId) {
            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            break;
        }
    }
}

#pragma mark - OpenTok methods
//Connect to a new room
- (void)doConnect
{    self.session = [[OTSession alloc] initWithSessionId:self.kSessionId
                                           delegate:self];
    [self.session addObserver:self
               forKeyPath:@"connectionCount"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    [self.session connectWithApiKey:self.kApiKey token:self.kToken];
}

- (void)doDisconnect
{
    [self.session disconnect];
}

//Publish the users stream. (Smaller box)
- (void)doPublish
{
    self.publisher = [[OTPublisher alloc] initWithDelegate:self name:UIDevice.currentDevice.name];
    self.publisher.publishAudio = YES;
    self.publisher.publishVideo = YES;
    [self.session publish:self.publisher];
    
    [self.publisher.view setFrame:CGRectMake(xOffsetUser, topOffsetUser, userVidWidth, userVidHeight)];
    self.publisher.view.layer.cornerRadius = 2;
    self.publisher.view.layer.borderWidth = 1;
    [self.userScreenContainer addSubview:self.publisher.view];
}



//Unpublish user stream
- (void)doUnpublish
{
    if (self.publisher) {
        [self.session unpublish:self.publisher];
        self.publisher = nil;
    }
}

#pragma mark - OTSessionDelegate methods
//Room is ready for shouting
- (void)sessionDidConnect:(OTSession*)session
{
   [self doPublish];
   // NSLog(@"sessionDidConnect: %@", session.sessionId);
   // NSLog(@"- connectionId: %@", session.connection.connectionId);
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
    NSLog(@"session: didReceiveStream:");
    //NSLog(@"- connection.connectionId: %@", stream.connection.connectionId);
    //NSLog(@"- connection.creationTime: %@", stream.connection.creationTime);
    //NSLog(@"- session.sessionId: %@", stream.session.sessionId);
    //NSLog(@"- streamId: %@", stream.streamId);
    //NSLog(@"- type %@", stream.type);
    //NSLog(@"- creationTime %@", stream.creationTime);
    //NSLog(@"- name %@", stream.name);
    if ( (subscribeToSelf && [stream.connection.connectionId isEqualToString: self.session.connection.connectionId])
        ||
        (!subscribeToSelf && ![stream.connection.connectionId isEqualToString: self.session.connection.connectionId])
        ) {
        if (!self.subscriber) {
            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            self.subscriber.subscribeToAudio = YES;
            self.subscriber.subscribeToVideo = YES;
        }
    }
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream
{
    NSLog(@"session didDropStream (%@)", stream.streamId);
    if (!subscribeToSelf
        && self.subscriber
        && [self.subscriber.stream.streamId isEqualToString: stream.streamId]) {
        self.subscriber = nil;
        [self updateSubscriber];
    }
}

#pragma mark - User Stream - OTPublisherDelegate methods

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error
{
    NSLog(@"publisher: %@ didFailWithError:", publisher);
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}

- (void)publisherDidStartStreaming:(OTPublisher *)publisher
{
    //NSLog(@"publisherDidStartStreaming: %@", publisher);
    //NSLog(@"- publisher.session: %@", publisher.session.sessionId);
    NSLog(@"- publisher.name: %@", publisher.name);
    self.statusLabel.text = @"publishing...";
}

-(void)publisherDidStopStreaming:(OTPublisher*)publisher
{
    //self._publishButton.hidden = NO;
    NSLog(@"publisherDidStopStreaming:%@", publisher);
}

#pragma mark - Opponent Stream - OTSubscriberDelegate methods
//opponent connected
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
