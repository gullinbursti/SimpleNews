//
//  SNAppDelegate.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "SNAppDelegate.h"

#import "SNSplashViewController_iPhone.h"
#import "SNSplashViewController_iPad.h"
#import "SNViewController_Airplay.h"

#import "Reachability.h"

@implementation SNAppDelegate

@synthesize windows;
//@synthesize window = _window;
//@synthesize viewController = _viewController;


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
	//[_window release];
	//[_viewController release];
	[super dealloc];
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	UIWindow *window = nil;
	
	windows = [[NSMutableArray alloc] init];
	NSLog(@"SCREENS:[%d]", [[UIScreen screens] count]);
	
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"airplay_enabled"];
	
	int cnt = 0;
	for (UIScreen *screen in [UIScreen screens]) {
		SNSplashViewController_iPhone *_viewController = nil;
		
		NSLog(@":::::::]] SCREEN[%d](%f, %f)", cnt, screen.bounds.size.width, screen.bounds.size.height);
		if (![SNAppDelegate hasWiFi]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Wi-Fi" message:@"Turn on network" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
		
		if (cnt == 0) {
			
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
				_viewController = [[SNSplashViewController_iPhone alloc] init];
			
			else
				_viewController = [[SNSplashViewController_iPad alloc] init];//_viewController = [[[SNSplashViewController_iPad alloc] initWithNibName:@"SNViewController_iPad" bundle:nil] autorelease];
			
		} else
			_viewController = [[SNViewController_Airplay alloc] initWithFrame:screen.bounds];
		
		window = [self createWindowForScreen:screen];
		
		[self addViewController:_viewController toWindow:window];
		[_viewController release];
		_viewController = nil;
		
		// If you don't do this here, you will get the "Applications are expected to have a root view controller" message.
		if (screen == [UIScreen mainScreen])
			[window makeKeyAndVisible];
		
		
		cnt++;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenDidConnect:) name:UIScreenDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenModeDidChange:) name:UIScreenModeDidChangeNotification object:nil];
	
	
	//-self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	//-self.viewController = [[[SNViewController alloc] initWithUserInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]] autorelease];
	
	/*
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		self.viewController = [[[SNViewController alloc] initWithNibName:@"SNViewController_iPhone" bundle:nil] autorelease];
	
	else
		self.viewController = [[[SNViewController alloc] initWithNibName:@"SNViewController_iPad" bundle:nil] autorelease];
	*/
	
	//-self.window.rootViewController = self.viewController;
	//-[self.window makeKeyAndVisible];
	
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenModeDidChangeNotification object:nil];
}


-(UIWindow *)createWindowForScreen:(UIScreen *)screen {
	UIWindow    *_window    = nil;
	
	// Do we already have a window for this screen?
	for (UIWindow *window in self.windows) {
		if (window.screen == screen)
			_window = window;
	}
	
	// Still nil? Create a new one.
	if (_window == nil) {
		_window = [[[UIWindow alloc] initWithFrame:[screen bounds]] autorelease];
		[_window setScreen:screen];
		[self.windows addObject:_window];
	}
	
	return (_window);
}

-(void)addViewController:(UIViewController *)controller toWindow:(UIWindow *)window {
	[window setRootViewController:controller];
	[window setHidden:NO];
}


-(void)_screenDidConnect:(NSNotification *)notification {
	UIScreen *connectedScreen = (UIScreen *)[notification object];
	NSLog(@":::::::]] SCREEN CONNECTED[%d](%f, %f)", [[UIScreen screens] count], connectedScreen.bounds.size.width, connectedScreen.bounds.size.height);
	
	UIWindow *window = [[UIWindow alloc] initWithFrame:connectedScreen.bounds];
	
	[window setScreen:connectedScreen];
	window.hidden = NO;
}

-(void)_screenDidDisconnect:(NSNotification *)notification {
	NSLog(@":::::::]] SCREEN DISCONNECTED");
}

-(void)_screenModeDidChange:(NSNotification *)notification {
	NSLog(@":::::::]] SCREEN MODE CHANGED");
}

@end
