//
//  SRDetailViewController.h
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRRoom.h"
#import "SRAPI.h"
#import <Opentok/Opentok.h>


@interface SRDetailViewController : UIViewController <OTPublisherDelegate, OTSessionDelegate, OTSubscriberDelegate>

@property (weak, nonatomic) IBOutlet UILabel *roomTitle;
@property (weak, nonatomic) IBOutlet UIView *userScreenContainer;
@property (weak, nonatomic) IBOutlet UIView *opponentScreenContainer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) SRRoom *room;

@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) OTPublisher* publisher;
@property (strong, nonatomic) OTSubscriber* subscriber;



@property dispatch_queue_t opentokQueue;

-(void)doCloseRoomId:(NSNumber *) roomId position:(NSString*)position;
@end
