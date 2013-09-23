//
//  SRAppDelegate.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.


#import "SRAppDelegate.h"
#import "TestFlight.h"

#define XCODE_COLORS_ESCAPE_MAC @"\033["
#define XCODE_COLORS_ESCAPE_IOS @"\xC2\xA0["

#if TARGET_OS_IPHONE
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_IOS
#else
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
#endif

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

@implementation SRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [self customizeNav];
    
    // start of your application:didFinishLaunchingWithOptions // ...
    [TestFlight takeOff:@"ac04c1e5-5155-4ca9-9ccd-40788feefe35"];
    
    return true;
}

-(void) customizeNav{
    //navigation controller
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    UIImage *navBackground = [UIImage imageNamed:@"NavBar.png"];
    [[UINavigationBar appearance] setBackgroundImage:navBackground forBarMetrics:UIBarMetricsDefault];
    
    
    
    
    setenv("XcodeColors", "YES", 0);
    
    NSLog(@"If you don't see colors below, make sure you follow the installation instructions in the README.");
    
	NSLog(XCODE_COLORS_ESCAPE @"fg0,0,255;" @"Blue text" XCODE_COLORS_RESET);
    
	NSLog(XCODE_COLORS_ESCAPE @"bg220,0,0;" @"Red background" XCODE_COLORS_RESET);
    
	NSLog(XCODE_COLORS_ESCAPE @"fg0,0,255;"
		  XCODE_COLORS_ESCAPE @"bg220,0,0;"
		  @"Blue text on red background"
		  XCODE_COLORS_RESET);
    
	NSLog(XCODE_COLORS_ESCAPE @"fg209,57,168;" @"You can supply your own RGB values!" XCODE_COLORS_RESET);
    
    /* Taken out because back button on SRDetailViewController needs custom functionality
    //set up back button
    UIImage *backButton = [UIImage imageNamed:@"backButton"];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000)forBarMetrics:UIBarMetricsDefault];
     */
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
