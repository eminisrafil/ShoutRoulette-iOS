//
//  SRDetailViewController.h
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRAPI.h"
#import "SRRoom.h"
#import "SROpenTokVideoHandler.h"
#import "SRUserStats.h"

@interface SRDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *roomTitle;
@property (weak, nonatomic) IBOutlet UIView *userScreenContainer;
@property (weak, nonatomic) IBOutlet UIView *opponentScreenContainer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIView *bottomViewContainer;

@property (strong, nonatomic) NSTimer *progressTimer;
@property (strong, nonatomic) NSTimer *retryTimer;

@property (strong, nonatomic) SRRoom *room;
@property (strong, nonatomic) SROpenTokVideoHandler *openTokHandler;

@end
