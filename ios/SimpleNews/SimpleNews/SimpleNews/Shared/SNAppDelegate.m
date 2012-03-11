//
//  SNAppDelegate.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"

#import "SNAppDelegate.h"


@implementation SNAppDelegate

@synthesize window = _window;


+(UIFont *)snHelveticaFontRegular {
	return ([UIFont fontWithName:@"Helvetica" size:14.0]);
}

+(UIFont *)snHelveticaFontBold {
	return ([UIFont fontWithName:@"Helvetica-Bold" size:14.0]);
}

+(UIFont *)snHelveticaFontItalic {
	return ([UIFont fontWithName:@"Helvetica-Oblique" size:14.0]);
}

+(UIFont *)snHelveticaFontBoldItalic {
	return ([UIFont fontWithName:@"Helvetica-BoldOblique" size:14.0]);
}

+(UIFont *)snHelveticaNeueFontRegular {
	return [UIFont fontWithName:@"HelveticaNeue" size:14.0];
}

+(UIFont *)snHelveticaNeueFontBold {
	return [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
}

+(UIFont *)snHelveticaNeueFontMedium {
	return [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
}

+(void)playMP3:(NSString *)filename {
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], filename]];
	
	AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	audioPlayer.numberOfLoops = 0;
	[audioPlayer play];
}


+(BOOL)hasWiFi {
	Reachability *wifiReachability = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReachability startNotifier];
	
	return ([wifiReachability currentReachabilityStatus] == kReachableViaWiFi);
}

+(BOOL)hasAirplay {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"airplay_enabled"] isEqualToString:@"YES"]);
}


+(int)minutesAfterDate:(NSDate *)date {
	return ([[NSDate new] timeIntervalSinceDate:date] / 60);
}

+(int)hoursAfterDate:(NSDate *)date {
	return ([[NSDate new] timeIntervalSinceDate:date] / 3600);
}

+(int)daysAfterDate:(NSDate *)date {
	return ([[NSDate new] timeIntervalSinceDate:date] / 86400);
}


-(void)dealloc {
	[_window release];
	
	[super dealloc];
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"airplay_enabled"];
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	
	UINavigationController *rootNavigationController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		_splashViewController_iPhone = [[SNSplashViewController_iPhone alloc] init];
		rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_splashViewController_iPhone] autorelease];
		
		//_gridViewController_iPhone = [[SNChannelGridViewController_iPhone alloc] init];
		//rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_gridViewController_iPhone] autorelease];
	
	} else {
		_gridViewController_iPad = [[SNVideoGridViewController_iPad alloc] init];
		rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_gridViewController_iPad] autorelease];
	}
	
	[rootNavigationController setNavigationBarHidden:YES];
	[self.window setRootViewController:rootNavigationController];
	[self.window makeKeyAndVisible];
	
	return (YES);
}

/**
 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
 **/
-(void)applicationWillResignActive:(UIApplication *)application {
}

/**
 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
 **/
-(void)applicationDidEnterBackground:(UIApplication *)application {
}

/**
 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
 **/
-(void)applicationWillEnterForeground:(UIApplication *)application {
}

/**
 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 **/
-(void)applicationDidBecomeActive:(UIApplication *)application {
}

/**
 Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
 **/
- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
