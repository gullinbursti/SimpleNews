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

static NSString *kFacebookAppId = @"316539575066102";
NSString *const kSNProfileInfoKey = @"ProfileInfo";

@implementation SNAppDelegate

@synthesize window = _window;
@synthesize facebook;
@synthesize userPermissions;

+(SNAppDelegate *)sharedInstance {
	return (SNAppDelegate *)[UIApplication sharedApplication].delegate;
}

+(Facebook *)facebook {
	return [[SNAppDelegate sharedInstance] facebook];
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
	[defaults setObject:@"NO" forKey:@"airplay_enabled"];
	[defaults synchronize];
	
	/*
	for (NSString *name in [UIFont familyNames]) {
		NSLog(@"Family name : %@", name);
		for (NSString *font in [UIFont fontNamesForFamilyName:name]) {
			NSLog(@"Font name : %@", font);             
		}
	}
	*/
	
	
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
		//_splashViewController_iPhone = [[SNSplashViewController_iPhone alloc] init];
		//rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_splashViewController_iPhone] autorelease];
		
		_rootViewController_iPhone = [[SNRootViewController_iPhone alloc] init];
		rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_rootViewController_iPhone] autorelease];
		
		
		// Initialize Facebook
		facebook = [[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:self];
		userPermissions = [[NSArray arrayWithObjects:@"read_stream", @"publish_stream", @"offline_access", @"user_location", nil] retain];
		
		// Check and retrieve authorization information
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
			facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
			facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
		}
		
		[rootNavigationController setNavigationBarHidden:YES];
		[self.window setRootViewController:rootNavigationController];
		[self.window makeKeyAndVisible];
		
		/*
		if (![facebook isSessionValid]) {
			[facebook authorize:userPermissions];
			
		} else {
			NSLog(@"ALREADY LOGGED IN");
		}
		*/
		
		if (![SNAppDelegate profileForUser]) {
			SNSplashViewController_iPhone *splashViewController = [[[SNSplashViewController_iPhone alloc] init] autorelease];
			UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:splashViewController] autorelease];
			
			[navigationController setNavigationBarHidden:YES];
			[rootNavigationController presentModalViewController:navigationController animated:NO];
		}
		
		// Show a splash screen immediately
		//SNSplashViewController_iPhone *splashViewController = [[[SNSplashViewController_iPhone alloc] init] autorelease];
		//UINavigationController *splashNavigationController = [[[UINavigationController alloc] initWithRootViewController:splashViewController] autorelease];
		//[splashNavigationController setNavigationBarHidden:YES animated:NO];
		//[rootNavigationController pushViewController:splashViewController animated:NO];
	
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
	[facebook extendAccessTokenIfNeeded];
	SNTwitterCaller *twitterCaller = [[[SNTwitterCaller alloc] init] autorelease];
}

/**
 Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
 **/
- (void)applicationWillTerminate:(UIApplication *)application {
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [facebook handleOpenURL:url]; 
}



-(void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
	[defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
	[defaults synchronize];
}


#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
	SNAppDelegate *delegate = (SNAppDelegate *)[[UIApplication sharedApplication] delegate];
	[self storeAuthData:[[delegate facebook] accessToken] expiresAt:[[delegate facebook] expirationDate]];
	
	NSLog(@"FB LOGGED IN");
	[facebook requestWithGraphPath:@"me" andDelegate:self];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
	NSLog(@"token extended");
	
	[self storeAuthData:accessToken expiresAt:expiresAt];
	[facebook requestWithGraphPath:@"me" andDelegate:self];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
	
	// Remove saved authorization information if it exists and it is
	// ok to clear it (logout, session invalid, app unauthorized)
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"FBAccessTokenKey"];
	[defaults removeObjectForKey:@"FBExpirationDateKey"];
	[defaults synchronize];
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Auth Exception" message:@"Your session has expired." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
	[self fbDidLogout];
}



#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	//NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
//	if ([result isKindOfClass:[NSArray class]]) {
//		result = [result objectAtIndex:0];
//	}
//	// This callback can be a result of getting the user's basic
//	// information or getting the user's permissions.
//	if ([result objectForKey:@"name"]) {
//		NSLog(@"%@", [result objectForKey:@"name"]);
//		UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"pic"]]]];
//		
//	} else {
//		// Processing permissions information
//		SNAppDelegate *delegate = (SNAppDelegate *)[[UIApplication sharedApplication] delegate];
//		[delegate setUserPermissions:[[result objectForKey:@"data"] objectAtIndex:0]];
//	}
	
	/*
	NSMutableDictionary *profile = [NSMutableDictionary new];
	if ([result isKindOfClass:[NSDictionary class]]) {
		NSString *strBirthDay = [[NSString alloc] initWithFormat:@"%@", [result objectForKey:@"birthday"]];
		NSString *strBirthYear = [[NSString alloc] initWithFormat:@"%@", [(NSArray *)[strBirthDay componentsSeparatedByString:@"/"] lastObject]];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"YYYY"];	  
		NSString *strCurrentYear = [formatter stringFromDate:[NSDate date]];
		
		[profile setObject:[result objectForKey:@"id"] forKey:@"id"];
		[profile setObject:[result objectForKey:@"username"] forKey:@"handle"];
		[profile setObject:[[NSString alloc] initWithFormat:@"%@ %@", [result objectForKey:@"first_name"], [result objectForKey:@"last_name"]] forKey:@"name"];
		[profile setObject:[result objectForKey:@"first_name"] forKey:@"fName"];
		[profile setObject:[result objectForKey:@"last_name"] forKey:@"lName"];
		[profile setObject:[result objectForKey:@"gender"] forKey:@"sex"];
		[profile setObject:[NSNumber numberWithInteger:[strCurrentYear intValue] - [strBirthYear intValue]] forKey:@"age"];
		[profile setObject:[(NSDictionary *)[result objectForKey:@"location"] objectForKey:@"name"] forKey:@"location"];
		[profile setObject:[(NSDictionary *)[result objectForKey:@"hometown"] objectForKey:@"name"] forKey:@"hometown"];
		[profile setObject:[(NSDictionary *)[(NSDictionary *)[(NSArray *)[result objectForKey:@"work"] objectAtIndex:0] objectForKey:@"employer"] objectForKey:@"name"] forKey:@"work"];
		[profile setObject:[(NSDictionary *)[(NSArray *)[result objectForKey:@"education"] lastObject] objectForKey:@"type"] forKey:@"education"];
		[profile setObject:@"" forKey:@"profession"];
		[profile setObject:@"0" forKey:@"friends"];
	}
	
	[SNAppDelegate writeFBProfile:profile];
	 */
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
	NSLog(@"Err code: %d", [error code]);
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
