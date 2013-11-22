//
//  SRSocialSharing.h
//  ShoutRoulette
//
//  Created by emin on 9/25/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SRSocialSharing : UIView <MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) NSString *sharingMessage;
@property (strong, nonatomic) NSURL *sharingURL;

- (IBAction)sharingServicePressed:(id)sender;

@end
