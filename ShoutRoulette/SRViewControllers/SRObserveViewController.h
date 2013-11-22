//
//  SRObserveViewController.h
//  ShoutRoulette
//
//  Created by emin on 9/27/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SROpenTokVideoHandler.h"
#import "SRAPI.h"
#import "SRRoom.h"
#import "SRAnimationHelper.h"

@interface SRObserveViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *roomTitle;
@property (weak, nonatomic) IBOutlet UIView *agreeShoutContainer;
@property (weak, nonatomic) IBOutlet UIView *disagreeShoutContainer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *topContainer;

@property (strong, nonatomic) SROpenTokVideoHandler *openTokHandler;
@property (strong, nonatomic) SRRoom *room;
@property (strong, nonatomic) NSTimer *retryTimer;

@end
