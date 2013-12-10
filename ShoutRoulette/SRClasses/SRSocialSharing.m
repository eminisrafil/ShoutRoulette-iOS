//
//  SRSocialSharing.m
//  ShoutRoulette
//
//  Created by emin on 9/25/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRSocialSharing.h"
#import <Social/Social.h>
#import "UIView+UIView_FindUIViewController.h"
#import "SRAnimationHelper.h"
#import <TestFlight.h>

@implementation SRSocialSharing

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		NSString *class_name = NSStringFromClass([self class]);
		NSArray *viewsArray = [[NSBundle mainBundle] loadNibNamed:class_name owner:self options:nil];
		UIView *mainView = viewsArray[0];
		[self addSubview:mainView];
	}
	return self;
}

- (IBAction)sharingServicePressed:(id)sender {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
	    UIImage *image = [UIImage imageNamed:@"icon-iOS7@2x"];
	    NSString *serviceType = [NSString new];
        
	    int tag = [sender tag];
	    switch (tag) {
			case 0:
				serviceType = SLServiceTypeFacebook;
				break;
                
			case 1:
				serviceType = SLServiceTypeTwitter;
				break;
                
			case 2:
				[self showSMS:[self formatTextMessage]];
				return;
                
			default:
				break;
		}
        
	    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
	    [controller addURL:[self formatUrl]];
	    [controller setInitialText:[self formatMessage]];
	    [controller addImage:image];
        
        
	    UIViewController *viewController = [self firstAvailableUIViewController];
        
	    dispatch_async(dispatch_get_main_queue(), ^(void) {
	        [viewController presentViewController:controller animated:YES completion:nil];
		});
	});
}

- (void)logTestFlight:(NSString *)service {
	[TestFlight passCheckpoint:[NSString stringWithFormat:@"Shared: %@", service]];
}

- (NSURL *)formatUrl {
	return (self.sharingURL) ? self.sharingURL : [NSURL URLWithString:kSRAPIHOST];
}

- (NSString *)formatMessage {
	NSString *message;
	if (!self.sharingMessage) {
		message = @"Verus me!";
	}
	else {
		message = self.sharingMessage;
	}
	return message;
}

- (NSString *)formatTextMessage {
	return [NSString stringWithFormat:@"%@ %@", [self formatMessage], [self formatUrl]];
}

- (void)showSMS:(NSString *)message {
	if (![MFMessageComposeViewController canSendText]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
    
	MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
	messageController.messageComposeDelegate = self;
	[messageController setBody:message];
    
    
	UIViewController *viewController = [self firstAvailableUIViewController];
	[viewController presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	switch (result) {
		case MessageComposeResultCancelled:
			break;
            
		case MessageComposeResultFailed:
		{
			UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[warningAlert show];
			break;
		}
            
		case MessageComposeResultSent:
			break;
            
		default:
			break;
	}
	if (controller) {
		[controller dismissViewControllerAnimated:YES completion:nil];
	}
}

@end

/*
 -(UIImage *)screenshot
 {
 CGRect rect;
 rect=CGRectMake(0, 10, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height-10);
 UIGraphicsBeginImageContext(rect.size);
 
 CGContextRef context=UIGraphicsGetCurrentContext();
 UIViewController *viewController = [self firstAvailableUIViewController];
 [[viewController navigationController].view.layer renderInContext:context];
 
 UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 viewController = nil;
 
 return image;
 }
 */
