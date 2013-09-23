//
//  SRDetailViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

//static int topOffsetUser = 3;
//static int xOffsetUser = 4;
static int topOffsetOpponent = 6;
static int xOffsetOpponent = 7;
static double opponentVidHeight = 220;
static double opponentVidWidth = 300;
//static double userVidHeight = 86;
//static double userVidWidth = 87;
//static bool subscribeToSelf = NO;

@interface SRDetailViewController ()

@property (strong, nonatomic) NSString* kApiKey;
@property (strong, nonatomic) NSString* kSessionId;
@property (strong, nonatomic) NSString* kToken;

@property BOOL safe;
@property (strong, nonatomic) NSString* state;
@property NSInteger* connectionCount;
@end

@implementation SRDetailViewController


-(void)viewWillAppear:(BOOL)animated{
    self.safe = YES;
    NSLog(@"ROOM DID APPEAR");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configOpentTok];
    [self performGetRoomRequest];
    [self configNavBar];
    [self configNotifcations];
    
    //[self updateStatusLabel:@"Connecting" withColor:[UIColor blackColor]];

}

-(void) configOpentTok{   
    [self.openTokHandler registerUserVideoStreamContainer:self.userScreenContainer];
    [self.openTokHandler registerOpponentOneVideoStreamContainer:self.opponentScreenContainer];
}

-(void) configNavBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressBackButton)];
    UIImage *backButtonImage = [UIImage imageNamed:@"backButton"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 47, 32)];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventAllEvents];
    UIBarButtonItem *navBackButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self.navigationItem setLeftBarButtonItem:navBackButton];
    
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backButton style: UIBarButtonItemStyleBordered target:self action:@selector(pressBackButton)];
    //[[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000)forBarMetrics:UIBarMetricsDefault];
}

-(void)pressBackButton{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self manageSafeClose];
    
    [self.openTokHandler safetlyCloseSession];
    double delayInSeconds = 0;
    //[self updateStatusLabel:@"Disconnecting" withColor:[UIColor grayColor]];

//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
    //});
}

-(void)configNotifcations
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recieveNotification:)
                                                 name:kSROpenTokVideoHandlerNotifcations
                                               object:nil
     ];
}

-(void)recieveNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:kSROpenTokVideoHandlerNotifcations]){
        NSDictionary *userInfo = notification.userInfo;
        NSNumber *message = [userInfo objectForKey:@"message"];
        [self statusMessage: message];
    }
}

-(void)statusMessage:(NSNumber*)message{
    
        NSString *result = nil;
        
        switch([message intValue]) {
            case 0:
                result = @"Disconnected";
                break;
            case 1:
                result = @"Connecting...";
                break;
            case 2:
                result = @"Publishing Your Video...";
                break;
            case 3:
                result = @"Searching for Idiots...";
                break;
            case 4:
                result = @"Start Shouting!";
                break;
            case 5:
                result = @"Opponent Stopped Shouting! You Win!";
                break;
            case 6:
                result = @"Disconnecting...";
                break;
                
                
            default:
                result = @"Retry";
        }

    [self updateStatusLabel:result withColor:[self statusLabelColorPicker:message]];
    NSLog(@"STATUS LABEL UPDATE: %@", message);

}

-(UIColor*)statusLabelColorPicker:(NSString *)Message{
    return [UIColor blackColor];

}

-(void)performGetRoomRequest{
    [[RKObjectManager sharedManager] getObject:self.room
                                          path:nil
                                    parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
            self.openTokHandler.kToken = self.room.token;
            self.openTokHandler.kSessionId = self.room.sessionId;
            self.roomTitle.text = self.room.title;
            self.navigationController.title = self.room.position;
            [self.openTokHandler doConnectToRoomWithSession];
        }failure:^(RKObjectRequestOperation *operation, NSError *error){
            //Retry?
    }];
}


-(void)viewDidDisappear:(BOOL)animated{
    [self doCloseRoomId:self.room.roomId position:self.room.position];
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    NSLog(@"ROOM DISAPPEARED! ");
}

-(void)manageSafeClose{
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
    //if ([keyPath isEqualToString:@"connectionCount"]) {
        //[self setStatusLabel];
    //}
}


#pragma mark - label
- (void)updateStatusLabel:(NSString *) message withColor:(UIColor*) color
{
    self.statusLabel.text = message;
    [self fadeOutFadeInAnimation:self.statusLabel andColor:color];
}

- (void)fadeOutFadeInAnimation:(UILabel *)label andColor:(UIColor*)color
{
    //Customize animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.FromValue = [NSNumber numberWithFloat:0.2f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.autoreverses = YES;
    //animation.BeginTime = CACurrentMediaTime()+.8;
    //animation.timingFuncti on = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = NO;
    animation.duration = 1;
    animation.repeatCount = 99;
    
    //add animation
    [label.layer addAnimation:animation forKey:nil];
    
    //change label color
    label.textColor = color;
}

-(void)stopAnimations:(UIView*) view{
    [view.layer removeAllAnimations];
}

-(UIColor *)darkGreen{
    return [UIColor colorWithRed:(0/255.0) green:(104/255.0) blue:(0/255.0) alpha:1];
}

-(void)retryButtonPressed:(id)sender{
    [self doCloseRoomId:self.room.roomId position:self.room.position];
    [self performGetRoomRequest];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

//- (void)updateSubscriber
//{
//    NSLog(@"updateing subscriber");
//    for (NSString* streamId in self.session.streams) {
//        OTStream* stream = [self.session.streams valueForKey:streamId];
//        if (stream.connection.connectionId != self.session.connection.connectionId) {
//            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
//            break;
//        }
//    }
//}
