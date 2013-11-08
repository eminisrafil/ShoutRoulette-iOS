//
//  SRObserveViewController.m
//  ShoutRoulette
//
//  Created by emin on 9/27/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRObserveViewController.h"
#import "SRNavBarHelper.h"
#import "SRStringHelper.h"
#import <TestFlight.h>

@interface SRObserveViewController ()

typedef NS_ENUM (NSInteger, SRRoomStatusKey) {
	SRStatusKeyDisconnected = 0,
	SRStatusKeyConnecting = 1,
	SRStatusKeySearchingForIdiots = 3,
	SRStatusKeyOneOpponent = 4,
	SRStatusKeyMatchOver = 5,
	SRStatusKeyDisconnecting = 6,
	SRStatusKeyOpponentFailed = 7,
	SRStatusKeySearchSucceededNoRooms = 77,
	SRStatusKeyObservingFullRoom = 88,
	SRStatusKeyEveryoneLeftWillRestart = 99
};

@end

@implementation SRObserveViewController

#pragma - This & SRDetailViewController will be refactored SRVideoRoomViewController base class
- (void)viewDidLoad {
	[super viewDidLoad];
	[self configOpentTok];
	[self performGetRoomRequest];
	[self configNavBar];
	[self configNotifcations];
	[TestFlight passCheckpoint:@"Loaded-Observe-VC"];
}

- (void)configOpentTok {
	self.openTokHandler.shouldPublish = NO;
	self.openTokHandler.isObserving = YES;
	[self.openTokHandler registerUserVideoStreamContainer:self.agreeShoutContainer];
	[self.openTokHandler registerOpponentOneVideoStreamContainer:self.disagreeShoutContainer];
}

- (void)configNavBar {
	UIBarButtonItem *navBackButton =
    [SRNavBarHelper buttonForNavBarWithImage:[UIImage imageNamed:@"backButton"]
                            highlightedImage:nil
                                    selector:@selector(pressBackButton)
                                      target:self];
	[self.navigationItem setLeftBarButtonItem:navBackButton];
}

- (void)pressBackButton {
	[self replaceLeftNaveBarItemWithActivityView];
	[self manageSafeClose];
    
	double delayInSeconds = kSRBackButtonDelayTime;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
	    [self.navigationController popViewControllerAnimated:YES];
	});
}

- (void)replaceLeftNaveBarItemWithActivityView {
	self.navigationItem.leftBarButtonItem.enabled = NO;
    
	UIBarButtonItem *activityView = [SRNavBarHelper activityIndicatorNavButton];
    
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self.navigationItem setLeftBarButtonItem:activityView animated:YES];
}

- (void)configNotifcations {
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(handleSROpenTokNotifications:)
	                                             name:kSROpenTokVideoHandlerNotifcations
	                                           object:nil
     ];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil
     ];
}

- (void)handleSROpenTokNotifications:(NSNotification *)notification {
	if ([[notification name] isEqualToString:kSROpenTokVideoHandlerNotifcations]) {
		NSDictionary *userInfo = notification.userInfo;
		NSNumber *message = [userInfo objectForKey:@"message"];
		[self updateRoomStatusForNumber:message];
	}
}

- (void)appWillResignActive {
	[self manageSafeClose];
	[self.navigationController popViewControllerAnimated:NO];
}

- (NSDictionary *)statusKeysAndMessages {
	NSDictionary *statusKeysAndMessages = @{ @0 : @"Disconnected",
                                          @1 : @"Connecting...",
                                          @3 : @"Searching for Idiots...",
                                          @4 : @"Searching for one more...",
                                          @5 : @"Match Over! Searching...",
                                          @6 : @"Disconnecting...",
                                          @7 : @"Searching for Idiots...",
                                          @77 : @"Searching for Idiots...",
                                          @88 : @"Observing Idiots",
                                          @99 : @"Everyone Left! Searching..." };
	return statusKeysAndMessages;
}

- (void)updateRoomStatusForNumber:(NSNumber *)message {
	NSString *result = [[self statusKeysAndMessages] objectForKey:message];
    
	switch ([message intValue]) {
		case SRStatusKeyDisconnected:
		case SRStatusKeySearchingForIdiots:
		case SRStatusKeySearchSucceededNoRooms:
			[self startRetryTimer];
			break;
            
		case SRStatusKeyConnecting:
		case SRStatusKeyDisconnecting:
		case SRStatusKeyObservingFullRoom:
			[self stopRetryTimer];
			break;
            
		case SRStatusKeyOneOpponent:
			//incase user disconnects and disconnection is never received
			[self stopRetryTimer];
			[TestFlight passCheckpoint:@"Observe-SRStatusKeyOneOpponent"];
			[self performSelector:@selector(retry) withObject:nil afterDelay:(60 * 3)];
			break;
            
		case SRStatusKeyMatchOver:
		case SRStatusKeyEveryoneLeftWillRestart:
		case SRStatusKeyOpponentFailed:
			[self stopRetryTimer];
			[self performSelector:@selector(retry) withObject:nil afterDelay:8];
			break;
            
		default:
			break;
	}
    
	if (!result) {
		result = @"Retry";
	}
    
	[self updateStatusLabel:result withColor:[self statusLabelColorPicker:message] animated:YES];
	NSLog(@"STATUS LABEL UPDATE: %@", result);
}

- (void)startRetryTimer {
	NSLog(@"Timer Started");
	[self stopRetryTimer];
	self.retryTimer  = [NSTimer scheduledTimerWithTimeInterval:20 //change to 60
	                                                    target:self
	                                                  selector:@selector(retry)
	                                                  userInfo:nil
	                                                   repeats:YES];
}

- (void)stopRetryTimer {
	NSLog(@"Timer Stopped");
	[self.retryTimer invalidate];
	self.retryTimer = nil;
}

- (void)retry {
	[self manageSafeClose];
	[self configOpentTok];
	[self configNotifcations];
	[self performSelector:@selector(performGetRoomRequest) withObject:nil afterDelay:4];
}

- (UIColor *)statusLabelColorPicker:(NSNumber *)Message {
	return [UIColor whiteColor];
}

- (void)performGetRoomRequest {

	__weak typeof(self) weakSelf = self;
	[[RKObjectManager sharedManager] getObject:weakSelf.room
	                                      path:nil
	                                parameters:nil
	                                   success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           weakSelf.roomTitle.text = weakSelf.room.title;
                                           if (weakSelf.room.token.length < 5  || weakSelf.room.sessionId.length < 5) {
                                               [weakSelf updateRoomStatusForNumber:@77];
                                               return;
                                           }
                                           weakSelf.openTokHandler.kToken = weakSelf.room.token;
                                           weakSelf.openTokHandler.kSessionId = weakSelf.room.sessionId;
                                           [weakSelf.openTokHandler doConnectToRoomWithSession];
                                       } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
                                           [weakSelf startRetryTimer];
                                       }];
}

- (void)manageSafeClose {
	[self stopRetryTimer];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self.openTokHandler safetlyCloseSession];
	[[RKObjectManager sharedManager].operationQueue cancelAllOperations];
	[self doPerformCloseRoomRequest];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doPerformCloseRoomRequest {
	if (self.room.roomId.intValue < 1) {
		return;
	}
	__weak typeof(self) weakSelf = self;
    
	[[RKObjectManager sharedManager] deleteObject:weakSelf.room
	                                         path:nil
	                                   parameters:nil
	                                      success:nil
	                                      failure:nil
     ];
}

- (void)dealloc {
	[SRAnimationHelper stopAnimations:self.statusLabel];
	[TestFlight passCheckpoint:@"Observe-VC-Closed"];
	self.room = nil;
	self.openTokHandler = nil;
	self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - label
- (void)updateStatusLabel:(NSString *)message withColor:(UIColor *)color animated:(BOOL)animated {
	self.statusLabel.text = message;
	if (animated) {
		[self fadeOutFadeInAnimation:self.statusLabel andColor:color];
	}
	else {
		[SRAnimationHelper stopAnimations:self.statusLabel];
	}
}

- (void)fadeOutFadeInAnimation:(UILabel *)label andColor:(UIColor *)color {
	[label.layer addAnimation:[SRAnimationHelper fadeOfRoomStatusLabel] forKey:nil];
    
	label.textColor = color;
}

@end
