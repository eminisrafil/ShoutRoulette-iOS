//
//  SRAppDelegate.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.


#import "SRAppDelegate.h"
#import "SRDetailViewController.h"
#import "SRMasterViewController.h"
#import "TestFlight.h"

@implementation SRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self customizeNavBar];
	[self chooseStoryBoard];

	[TestFlight takeOff:kSRTestFlightAPIKey];
    
	if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil) {
		NSURL *url =
        (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
		[self application:application handleOpenURL:url];
	}
    
	return true;
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [self application:application handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {   
	[[NSNotificationCenter defaultCenter] postNotificationName:kSRFetchRoomFromUrl object:nil userInfo:@{ @"url" : url }];
    
	return YES;
}

- (void)customizeNavBar {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	UIImage *navBackground = [UIImage imageNamed:@"navBar.png"];
	[[UINavigationBar appearance] setBackgroundImage:navBackground forBarMetrics:UIBarMetricsDefault];

	/*  
     UIImage *backButton = [UIImage imageNamed:@"backButton"];
     [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
     [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000)forBarMetrics:UIBarMetricsDefault];
	 */
}

//Check For iPad Later
- (void)chooseStoryBoard {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		UIStoryboard *storyBoard;
		CGSize result = [[UIScreen mainScreen] bounds].size;
		CGFloat scale = [UIScreen mainScreen].scale;
		result = CGSizeMake(result.width * scale, result.height * scale);
        
		if (result.height == 1136) {
			storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard-iOS6" bundle:nil];
			UIViewController *initViewController = [storyBoard instantiateInitialViewController];
			[self.window setRootViewController:initViewController];
		}
		else {
			storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard-iOS6" bundle:nil];
			UIViewController *initViewController = [storyBoard instantiateInitialViewController];
			[self.window setRootViewController:initViewController];
		}
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
