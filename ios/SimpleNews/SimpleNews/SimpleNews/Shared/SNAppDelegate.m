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
#import "SNSplashViewController_iPhone.h"
#import "SNTwitterCaller.h"

NSString *const kSNProfileInfoKey = @"ProfileInfo";

@implementation SNAppDelegate

@synthesize window = _window;
@synthesize userPermissions;

+(SNAppDelegate *)sharedInstance {
	return (SNAppDelegate *)[UIApplication sharedApplication].delegate;
}

+(NSString *)subscribedInfluencers {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"influencers"]);
}


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

+(UIFont *)snAllerFontRegular {
	return [UIFont fontWithName:@"Aller" size:14.0];
}

+(UIFont *)snAllerFontBold {
	return [UIFont fontWithName:@"Aller-Bold" size:14.0];
}

+(UIFont *)snAllerFontItalic {
	return [UIFont fontWithName:@"Aller-Italic" size:14.0];
}

+(UIFont *)snAllerFontBoldItalic {
	return [UIFont fontWithName:@"Aller-BoldItalic" size:14.0];
}

+(UIColor *)snLineColor {
	return ([UIColor colorWithWhite:0.702 alpha:1.0]);
}

+(UIColor *)snHeaderColor {
	return ([UIColor colorWithWhite:0.941 alpha:1.0]);
}



+(void)playMP3:(NSString *)filename {
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], filename]];
	
	AVAudioPlayer *audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil] autorelease];
	audioPlayer.numberOfLoops = 0;
	[audioPlayer play];
}


+(BOOL)hasWiFi {
	Reachability *wifiReachability = [[[Reachability reachabilityForLocalWiFi] retain] autorelease];
	[wifiReachability startNotifier];
	
	return ([wifiReachability currentReachabilityStatus] == kReachableViaWiFi);
	
//	Reachability *hostReachability = [Reachability reachabilityForInternetConnection];	
//	NetworkStatus networkStatus = [hostReachability currentReachabilityStatus];	
//	return !(networkStatus == NotReachable);
}

+(BOOL)hasAirplay {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"airplay_enabled"] isEqualToString:@"YES"]);
}

+(int)secondsAfterDate:(NSDate *)date {
	return ([[[NSDate new] autorelease] timeIntervalSinceDate:date]);
}

+(int)minutesAfterDate:(NSDate *)date {
	return ([[[NSDate new] autorelease] timeIntervalSinceDate:date] / 60);
}

+(int)hoursAfterDate:(NSDate *)date {;
	return ([[[NSDate new] autorelease] timeIntervalSinceDate:date] / 3600);
}

+(int)daysAfterDate:(NSDate *)date {
	return ([[[NSDate new] autorelease] timeIntervalSinceDate:date] / 86400);
}


+(void)writeDeviceToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)deviceToken {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]);
}


+(void)writeFontFactor:(int)factor {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:factor] forKey:@"uiFontFactor"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(int)fontFactor {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"uiFontFactor"] intValue]);
}

+(void)writeDarkStyleUI:(BOOL)isDark {
	NSString *bool_str;
	if (isDark)
		bool_str = [NSString stringWithString:@"YES"];
	
	else
		bool_str = [NSString stringWithString:@"NO"];
	
	[[NSUserDefaults standardUserDefaults] setObject:bool_str forKey:@"uiDarkStyle"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isDarkStyleUI {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"uiDarkStyle"] isEqualToString:@"YES"]);
}



+(void)notificationsToggle:(BOOL)isOn {
	NSString *bool_str;
	if (isOn)
		bool_str = [NSString stringWithString:@"YES"];
	
	else
		bool_str = [NSString stringWithString:@"NO"];
	
	[[NSUserDefaults standardUserDefaults] setObject:bool_str forKey:@"notifications"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)notificationsEnabled {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] isEqualToString:@"YES"]);
}


+(void)twitterToggle:(BOOL)isSignedIn {
	NSString *bool_str;
	if (isSignedIn)
		bool_str = [NSString stringWithString:@"YES"];
	
	else
		bool_str = [NSString stringWithString:@"NO"];
	
	[[NSUserDefaults standardUserDefaults] setObject:bool_str forKey:@"twitter"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)twitterEnabled {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"twitter"] isEqualToString:@"YES"]);
}


+(NSString *)twitterHandle {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"twitterHandle"]);
}

+(NSString *)twitterAvatar {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"twitterAvatar"]);
}


+(NSDictionary *)fbProfile {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kSNProfileInfoKey];
}

+(BOOL)isProfileInfoAvailable {
	return ([self fbProfile] != nil);
}

+(void)writeFBProfile:(NSDictionary *)profile {
	
	if (profile != nil)
		[[NSUserDefaults standardUserDefaults] setObject:profile forKey:kSNProfileInfoKey];
	
	else
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kSNProfileInfoKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}


+(void)writeUserProfile:(NSDictionary *)userInfo {
	[[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"user_info"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)profileForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"]);
}


-(void)dealloc {
	[_window release];
	
	[super dealloc];
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	
	if(![defaults objectForKey:@"uiFontFactor"])
		[SNAppDelegate writeFontFactor:2];
	
	
	if(![defaults objectForKey:@"uiDarkStyle"])
		[SNAppDelegate writeDarkStyleUI:NO];
	
	
	NSArray *fontSizes = [NSArray arrayWithObjects:
								 [NSArray arrayWithObjects:[NSNumber numberWithInt:12], [NSNumber numberWithInt:12], [NSNumber numberWithInt:10], [NSNumber numberWithInt:8], nil], 
								 [NSArray arrayWithObjects:[NSNumber numberWithInt:14], [NSNumber numberWithInt:13], [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], nil], 
								 [NSArray arrayWithObjects:[NSNumber numberWithInt:16], [NSNumber numberWithInt:14], [NSNumber numberWithInt:12], [NSNumber numberWithInt:16], nil], 
								 [NSArray arrayWithObjects:[NSNumber numberWithInt:18], [NSNumber numberWithInt:16], [NSNumber numberWithInt:13], [NSNumber numberWithInt:24], nil], 
								 nil];
	
	[defaults setObject:fontSizes forKey:@"uiFontSizes"];
	[defaults synchronize];
	
	/*
	for (NSString *name in [UIFont familyNames]) {
		NSLog(@"Family name : %@", name);
		for (NSString *font in [UIFont fontNamesForFamilyName:name]) {
			NSLog(@"Font name : %@", font);             
		}
	}
	*/
	
	if (![SNAppDelegate hasWiFi]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Wi-Fi Connection" message:@"Please connect to a wi-fi ." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		[alert release];
	}
	
	
	SNTwitterCaller *twitterCaller = [[[SNTwitterCaller alloc] init] autorelease];
	
	if (![defaults objectForKey:@"boot_total"]) {
		[defaults setObject:[NSNumber numberWithInt:0] forKey:@"boot_total"];
		[defaults synchronize];
	
	} else {
		int boot_total = [[defaults objectForKey:@"boot_total"] intValue];
		boot_total++;
		
		[defaults setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
		[defaults synchronize];
		
		if ([[defaults objectForKey:@"boot_total"] intValue] > 2) {
			if (![[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] || [SNAppDelegate notificationsEnabled]) {
				[SNAppDelegate notificationsToggle:YES];
				
				// init Airship launch options
				NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
				[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
				
				// create Airship singleton that's used to talk to Urban Airhship servers, populate AirshipConfig.plist with your info from http://go.urbanairship.com
				[UAirship takeOff:takeOffOptions];
				[[UAPush shared] resetBadge];//zero badge on startup
				[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
			}	
		}
	}
	
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	UINavigationController *rootNavigationController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		
		if (![SNAppDelegate profileForUser]) {
			_splashViewController_iPhone = [[SNSplashViewController_iPhone alloc] init];
			rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_splashViewController_iPhone] autorelease];
		
		} else {
			_rootViewController_iPhone = [[SNRootViewController_iPhone alloc] init];
			rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_rootViewController_iPhone] autorelease];
		}
		
		[rootNavigationController setNavigationBarHidden:YES];
		[self.window setRootViewController:rootNavigationController];
		[self.window makeKeyAndVisible];
	
	} else {
		//_gridViewController_iPad = [[SNVideoGridViewController_iPad alloc] init];
		//rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_gridViewController_iPad] autorelease];
	}
	
	
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
	SNTwitterCaller *twitterCaller = [[[SNTwitterCaller alloc] init] autorelease];
}

/**
 Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
 **/
- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - PushNotification Delegates
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	UALOG(@"APN device token: %@", deviceToken);
	// Updates the device token and registers the token with UA
	[[UAPush shared] registerDeviceToken:deviceToken];
	
	NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	[SNAppDelegate writeDeviceToken:deviceID];
	
	//NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	//deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	//deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	//[DIAppDelegate setDeviceToken:deviceID];
	
	/*
	 * Some example cases where user notifcation may be warranted
	 *
	 * This code will alert users who try to enable notifications
	 * from the settings screen, but cannot do so because
	 * notications are disabled in some capacity through the settings
	 * app.
	 * 
	 */
	
	/*
    
    //Do something when notifications are disabled altogther
    if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
	 UALOG(@"iOS Registered a device token, but nothing is enabled!");
	 
	 //only alert if this is the first registration, or if push has just been
	 //re-enabled
	 if ([UAirship shared].deviceToken != nil) { //already been set this session
	 NSString* okStr = @"OK";
	 NSString* errorMessage =
	 @"Unable to turn on notifications. Use the \"Settings\" app to enable notifications.";
	 NSString *errorTitle = @"Error";
	 UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
	 message:errorMessage
	 delegate:nil
	 cancelButtonTitle:okStr
	 otherButtonTitles:nil];
	 
	 [someError show];
	 [someError release];
	 }
	 
    //Do something when some notification types are disabled
    } else if ([application enabledRemoteNotificationTypes] != [UAPush shared].notificationTypes) {
	 
	 UALOG(@"Failed to register a device token with the requested services. Your notifications may be turned off.");
	 
	 //only alert if this is the first registration, or if push has just been
	 //re-enabled
	 if ([UAirship shared].deviceToken != nil) { //already been set this session
	 
	 UIRemoteNotificationType disabledTypes = [application enabledRemoteNotificationTypes] ^ [UAPush shared].notificationTypes;
	 
	 
	 
	 NSString* okStr = @"OK";
	 NSString* errorMessage = [NSString stringWithFormat:@"Unable to turn on %@. Use the \"Settings\" app to enable these notifications.", [UAPush pushTypeString:disabledTypes]];
	 NSString *errorTitle = @"Error";
	 UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
	 message:errorMessage
	 delegate:nil
	 cancelButtonTitle:okStr
	 otherButtonTitles:nil];
	 
	 [someError show];
	 [someError release];
	 }
    }
	 
	 */
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
	
	[SNAppDelegate writeDeviceToken:[NSString stringWithFormat:@"%064d", 0]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	UALOG(@"Received remote notification: %@", userInfo);
	
	// Get application state for iOS4.x+ devices, otherwise assume active
	UIApplicationState appState = UIApplicationStateActive;
	if ([application respondsToSelector:@selector(applicationState)]) {
		appState = application.applicationState;
	}
	
	[[UAPush shared] handleNotification:userInfo applicationState:appState];
	[[UAPush shared] resetBadge]; // zero badge after push received
	
	//[UAPush shared].delegate = self;
	
	/*
	int type_id = [[userInfo objectForKey:@"type"] intValue];
	NSLog(@"TYPE: [%d]", type_id);
	
	switch (type_id) {
		case 1:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_REWARDS_LIST" object:nil];
			break;
			
		case 2:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_REWARDS_LIST" object:nil];
			break;
			
		case 3:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_DEVICES_LIST" object:nil];
			break;
			
		case 4:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"THANK_YOU_RECIEVED" object:nil];
			break;
			
	}

	 if (type_id == 2) {
	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leaving diddit" message:@"Your iTunes gift card number has been copied" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:@"Visit iTunes", nil];
	 [alert show];
	 [alert release];
	 
	 NSString *redeemCode = [[DIAppDelegate md5:[NSString stringWithFormat:@"%d", arc4random()]] uppercaseString];
	 redeemCode = [redeemCode substringToIndex:[redeemCode length] - 12];
	 
	 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	 [pasteboard setValue:redeemCode forPasteboardType:@"public.utf8-plain-text"];
	 }
	 
	 UILocalNotification *localNotification = [[[UILocalNotification alloc] init] autorelease];
	 localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:5];
	 localNotification.alertBody = [NSString stringWithFormat:@"%d", [[userInfo objectForKey:@"type"] intValue]];;
	 localNotification.soundName = UILocalNotificationDefaultSoundName;
	 localNotification.applicationIconBadgeNumber = 3;
	 
	 NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
	 localNotification.userInfo = infoDict;
	 
	 [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	 */
}



@end
