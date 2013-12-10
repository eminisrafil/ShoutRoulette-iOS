//
//  SRDetailViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRDetailViewController.h"
#import "SRNavBarHelper.h"
#import "SRSocialSharing.h"
#import "SRAnimationHelper.h"
#import "SRStringHelper.h"
#import <TestFlight.h>

@interface SRDetailViewController ()

typedef NS_ENUM (NSInteger, SRStatusKey) {
	SRStatusKeyDisconnected = 0,
	SRStatusKeyConnecting = 1,
	SRStatusKeyPublishing = 2,
	SRStatusKeySearchingForOpponent = 3,
	SRStatusKeyOpponentConnected = 4,
	SRStatusKeyOpponentDisconnected = 5,
	SRStatusKeyDisconnecting = 6,
	SRStatusKeyOpponentFailed = 7,
	SRStatusKeyTimeExpired = 8
};

@end

@implementation SRDetailViewController

#pragma - This & SRObserveViewController will be refactored SRVideoRoomViewController base class
- (void)viewDidLoad {
	[super viewDidLoad];
    
	[self configOpentTok];
	[self performGetRoomRequest];
	[self configNavBar];
	[self configNotifcations];
	[self configProgressBar];
	[self displayFirstShoutMessage];
	[TestFlight passCheckpoint:@"Loaded-Detail-VC"];
}

- (void)configSocialSharing {
	for (UIView *subview in self.view.subviews) {
		if ([subview isKindOfClass:[SRSocialSharing class]]) {
			return;
		}
	}
    
	//add off screen
	CGRect frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, 44);
	SRSocialSharing *share = [[SRSocialSharing alloc] initWithFrame:frame];
	[self.view addSubview:share];
    
	share.sharingURL = [self createUrlForSharing];
	share.sharingMessage = [self createMessageForSharing];
    
	//animate in
	frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 100, [[UIScreen mainScreen] bounds].size.width, 44);
	[UIView animateWithDuration:3 delay:2 options:UIViewAnimationOptionCurveEaseOut animations: ^{
	    share.frame = frame;
	} completion:nil];
}

- (NSURL *)createUrlForSharing {
	NSString *shortSessionId = [SRStringHelper trimSessionId:self.room.sessionId];
	NSString *urlString = [NSString stringWithFormat:@"%@invites/%@/%@?q=%@", kSRAPIHOST, self.room.topicId, [SRStringHelper opposingPosition:self.room.position], shortSessionId];
	return [NSURL URLWithString:urlString];
}

- (NSString *)createMessageForSharing {
	NSString *opponentsStance = [SRStringHelper opposingPosition:self.room.position];
	opponentsStance = [SRStringHelper capitalizeFirstLetter:opponentsStance];
    
	return [NSString stringWithFormat:@"%@ | %@?", self.room.title, opponentsStance];
}

- (void)configOpentTok {
	[self.openTokHandler registerUserVideoStreamContainer:self.userScreenContainer];
	self.openTokHandler.userVideoStreamName = self.room.position;
    
	[self.openTokHandler registerOpponentOneVideoStreamContainer:self.opponentScreenContainer];
	self.openTokHandler.opponentOneVideoStreamName = [SRStringHelper opposingPosition:self.room.position];
    
	self.openTokHandler.shouldPublish = YES;
	self.openTokHandler.isObserving = NO;
}

- (void)configNavBar {
	UIBarButtonItem *navBackButton =
    [SRNavBarHelper buttonForNavBarWithImage:[UIImage imageNamed:@"backButton"]
                            highlightedImage:nil
                                    selector:@selector(pressBackButton)
                                      target:self
     ];
	[self.navigationItem setLeftBarButtonItem:navBackButton];
    
	self.title = [SRStringHelper capitalizeFirstLetter:self.room.position];
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

- (void)appWillResignActive {
	[self manageSafeClose];
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)handleSROpenTokNotifications:(NSNotification *)notification {
	if ([[notification name] isEqualToString:kSROpenTokVideoHandlerNotifcations]) {
		NSDictionary *userInfo = notification.userInfo;
		NSNumber *message = [userInfo objectForKey:@"message"];
		[self updateRoomStatusForNumber:message];
	}
}

- (NSDictionary *)statusKeysAndMessages {
	NSDictionary *statusKeysAndMessages = @{
                                            @0 : @"Disconnected",
                                            @1 : @"Connecting...",
                                            @2 : @"Searching for Idiots...",
                                            @3 : @"Searching for Idiots...",
                                            @4 : @"Start Shouting!",
                                            @5 : @"Opponent Stopped Shouting! Well done!",
                                            @6 : @"Disconnecting...",
                                            @7 : @"Searching for Idiots...",
                                            @8 : @"Time Up! Match Over! Searching...",
                                            @77 : @"Searching for Idiots...",
                                            @88 : @"Observing Idiots",
                                            @99 : @"Everyone Left! Searching..."
                                            };
	return statusKeysAndMessages;
}

- (void)updateRoomStatusForNumber:(NSNumber *)message {
	NSString *result = [[self statusKeysAndMessages] objectForKey:message];
    
	switch ([message intValue]) {
		case SRStatusKeyDisconnected:
		case SRStatusKeyPublishing:
		case SRStatusKeySearchingForOpponent:
			break;
            
		case SRStatusKeyConnecting:
			[self startRetryTimer];
			break;
            
		case SRStatusKeyOpponentConnected:
			[self startProgressBar];
			[self stopTimer:self.retryTimer];
			[TestFlight passCheckpoint:@"DetailVC-Connected-To-Opponent"];
			break;
            
		case SRStatusKeyOpponentDisconnected:
			[self closeSessionAndRetryWithDelay:6];
			[self stopTimer:self.progressTimer];
			break;
            
		case SRStatusKeyDisconnecting:
			[self stopTimer:self.progressTimer];
			break;
            
		case SRStatusKeyOpponentFailed:
			[self closeSessionAndRetryWithDelay:3];
			break;
            
		case SRStatusKeyTimeExpired:
			[self closeSessionAndRetryWithDelay:5];
			break;
            
		default:
			result = @"Retry";
	}
    
	[self updateStatusLabel:result withColor:[self statusLabelColorPicker:message] animated:YES];
	NSLog(@"STATUS LABEL UPDATE: %@", result);
}

- (void)closeSessionAndRetryWithDelay:(float)delay {
	[self.openTokHandler safetlyCloseSession];
	[self performSelector:@selector(retry) withObject:nil afterDelay:delay];
}

- (UIColor *)statusLabelColorPicker:(NSNumber *)Message {
	//will update colors depending on state later
	return [UIColor whiteColor];
}

- (void)performGetRoomRequest {
	[TestFlight passCheckpoint:@"DetailVC-PerformedGetRoomRequest"];
	__weak typeof(self) weakSelf = self;
    
	[[RKObjectManager sharedManager] getObject:weakSelf.room
	                                      path:nil
	                                parameters:nil
	                                   success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           weakSelf.openTokHandler.kToken = weakSelf.room.token;
                                           weakSelf.openTokHandler.kSessionId = weakSelf.room.sessionId;
                                           weakSelf.roomTitle.text = weakSelf.room.title;
                                           weakSelf.navigationController.title = weakSelf.room.position;
                                           [weakSelf configSocialSharing];
                                           [weakSelf.openTokHandler doConnectToRoomWithSession];
                                       } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
                                           [self performSelector:@selector(retry) withObject:nil afterDelay:4];
                                       }];
}

- (void)displayFirstShoutMessage {
	SRUserStats *userStats = [[SRUserStats alloc]init];
	[userStats displayFirstMatchMessage];
	[userStats incrementStat:@"shouts"];
}

- (void)manageSafeClose {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self stopTimer:self.retryTimer];
	[self stopTimer:self.progressTimer];
	[self.openTokHandler safetlyCloseSession];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[RKObjectManager sharedManager].operationQueue cancelAllOperations];
	[self doPerformCloseRoomRequest];
}

- (void)dealloc {
	[SRAnimationHelper stopAnimations:self.statusLabel];
	self.openTokHandler = nil;
	self.room = nil;
	self.title = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[TestFlight passCheckpoint:@"DetailVC-Closed"];
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

- (void)startRetryTimer {
	NSLog(@"Retry Timer Started");
	self.retryTimer  = [NSTimer scheduledTimerWithTimeInterval:(60 * 5) //change to 5 min
	                                                    target:self
	                                                  selector:@selector(retry)
	                                                  userInfo:nil
	                                                   repeats:YES];
}

- (void)retry {
	[self manageSafeClose];
    
	if ([self.navigationController.visibleViewController isKindOfClass:[SRDetailViewController class]]) {
		double delayInSeconds = kSRBackButtonDelayTime;
		dispatch_time_t popTime = (DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		    [self configOpentTok];
		    [self configNotifcations];
		    [self performSelector:@selector(performGetRoomRequest) withObject:nil afterDelay:4];
		});
	}
}

#pragma mark - label
- (void)updateStatusLabel:(NSString *)message withColor:(UIColor *)color animated:(BOOL)animated {
	__weak typeof(self) weakSelf = self;
    
	dispatch_async(dispatch_get_main_queue(), ^{
	    weakSelf.statusLabel.text = message;
	    if (animated) {
	        [weakSelf fadeOutFadeInAnimation:weakSelf.statusLabel andColor:color];
		}
	    else {
	        [SRAnimationHelper stopAnimations:weakSelf.statusLabel];
		}
	});
}

- (void)fadeOutFadeInAnimation:(UILabel *)label andColor:(UIColor *)color {
	[label.layer addAnimation:[SRAnimationHelper fadeOfRoomStatusLabel] forKey:nil];
    
	label.textColor = color;
}

#pragma mark - Progress Bar
- (void)configProgressBar {
	self.bottomViewContainer.backgroundColor = [UIColor blackColor];
	self.progressBar.progressTintColor = [UIColor orangeColor];
}

- (void)startProgressBar {
	[self.progressBar.layer addAnimation:[SRAnimationHelper fadeInOfProgressBar] forKey:nil];
	self.progressBar.alpha = 1;
	self.progressBar.progress = 0;
	self.progressTimer  = [NSTimer scheduledTimerWithTimeInterval:.5
	                                                       target:self
	                                                     selector:@selector(changeProgressValue)
	                                                     userInfo:nil
	                                                      repeats:YES];
}

- (void)stopTimer:(NSTimer *)timer {
	[timer invalidate];
	timer = nil;
}

- (void)changeProgressValue {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	    BOOL complete = NO;
	    float progressValue = self.progressBar.progress;
	    progressValue += .00834;
        
	    if (progressValue > .99) {
	        progressValue = 1;
	        [self stopTimer:self.progressTimer];
	        complete = true;
		}
        
	    NSString *time = [NSString stringWithFormat:@"%.0f", 60 - ceil(progressValue * 60)];
	    NSString *message = [NSString stringWithFormat:@"Time Left: %@",  time];
        
	    dispatch_async(dispatch_get_main_queue(), ^(void) {
	        self.progressBar.progress      = progressValue;
	        [self updateStatusLabel:message withColor:[UIColor whiteColor] animated:NO];
	        if (complete == YES) {
	            [self updateRoomStatusForNumber:@8];
			}
		});
	});
}

@end
