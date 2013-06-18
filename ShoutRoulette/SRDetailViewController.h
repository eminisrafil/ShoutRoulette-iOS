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

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) SRRoom *room;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *token;
@property (weak, nonatomic) IBOutlet UIView *opponentVidContainer;
@property (weak, nonatomic) IBOutlet UIView *userVidContainer;
@property (weak, nonatomic) IBOutlet UILabel *roomTitle;
@property (strong, nonatomic) RKObjectManager *objectManager;


@property (strong, nonatomic) OTSession* _session;
@property (strong, nonatomic) OTPublisher* _publisher;
@property (strong, nonatomic) OTSubscriber* _subscriber;

@property (strong, nonatomic) NSString* kApiKey;    // Replace with your API Key
@property (strong, nonatomic) NSString* kSessionId; // Replace with your generated Session ID
@property (strong, nonatomic) NSString* kToken;     // Replace with your generated Token (use Project Tools or from a server-side library)


-(void)doCloseRoomId:(NSNumber *) roomId position:(NSString*)position;
@end
