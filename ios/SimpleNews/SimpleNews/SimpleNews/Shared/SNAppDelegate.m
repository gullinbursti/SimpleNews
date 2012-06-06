//
//  SNAppDelegate.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
#import "GANTracker.h"

#import "SNAppDelegate.h"
#import "SNSplashViewController_iPhone.h"
#import "SNTwitterCaller.h"

NSString *const kSNProfileInfoKey = @"ProfileInfo";

static const NSInteger kGANDispatchPeriodSec = 10;
static NSString* const kAnalyticsAccountId = @"UA-00000000-1";
static const NSInteger kLaunchesUntilRateRequest = 16;
static const NSInteger kDaysUntilRateRequest = 5;
static const BOOL kIsGoogleAnalyticsLive = NO;

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

+(UIColor *)snLinkColor {
	return ([UIColor colorWithRed:0.000 green:0.357 blue:0.953 alpha:1.0]);
}


+(UIColor *)snDebugRedColor {
	return ([UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.33]);
}

+(UIColor *)snDebugGreenColor {
	return ([UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.33]);
}

+(UIColor *)snDebugBlueColor {
	return ([UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.33]);
}


+(void)playMP3:(NSString *)filename {
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], filename]];
	
	AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	audioPlayer.numberOfLoops = 0;
	[audioPlayer play];
}


+(BOOL)hasNetwork {
	//Reachability *wifiReachability = [Reachability reachabilityForLocalWiFi];
	//[wifiReachability startNotifier];
	
	//return ([wifiReachability currentReachabilityStatus] == kReachableViaWiFi);
	
	Reachability *hostReachability = [Reachability reachabilityForInternetConnection];	
	NetworkStatus networkStatus = [hostReachability currentReachabilityStatus];	
	
	return !(networkStatus == NotReachable);
}

+(BOOL)hasAirplay {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"airplay_enabled"] isEqualToString:@"YES"]);
}

+(int)secondsAfterDate:(NSDate *)date {
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	return ([utcDate timeIntervalSinceDate:date]);
}

+(int)minutesAfterDate:(NSDate *)date {
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	return ([utcDate timeIntervalSinceDate:date] / 60);
}

+(int)hoursAfterDate:(NSDate *)date {
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	return ([utcDate timeIntervalSinceDate:date] / 3600);
}

+(int)daysAfterDate:(NSDate *)date {
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	return ([utcDate timeIntervalSinceDate:date] / 86400);
}


+ (void)openWithAppStore:(NSString *)url {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"http:" withString:@"itms-apps:"]]];
}


+(UIImage *)imageWithFilters:(UIImage *)srcImg filter:(NSArray *)fxList {
	UIImage *fxImg = srcImg;
	UIImage *outImg;
	
	for (NSDictionary *filter in fxList) {
		//NSLog(@"%f", [[filter objectForKey:@"amount"] doubleValue]);
		
		if ([[filter objectForKey:@"type"] isEqualToString:@"adjust"])
			outImg = [fxImg adjust:[[filter objectForKey:@"red"] doubleValue] g:[[filter objectForKey:@"green"] doubleValue] b:[[filter objectForKey:@"blue"] doubleValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"bias"])
			outImg = [fxImg bias:[[filter objectForKey:@"amount"] doubleValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"blur"])
			outImg = [fxImg gaussianBlur:[[filter objectForKey:@"amount"] intValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"brightness"])
			outImg = [fxImg brightness:[[filter objectForKey:@"amount"] doubleValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"contrast"])
			outImg = [fxImg contrast:[[filter objectForKey:@"amount"] doubleValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"darkVignette"])
			outImg = [fxImg darkVignette];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"gamma"])
			outImg = [fxImg gamma:[[filter objectForKey:@"amount"] doubleValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"greyscale"])
			outImg = [fxImg greyscale];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"invert"])
			outImg = [fxImg invert];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"levels"])
			outImg = [fxImg levels:[[filter objectForKey:@"shadow"] intValue] mid:[[filter objectForKey:@"mid"] intValue] white:[[filter objectForKey:@"hilight"] intValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"lomo"])
			outImg = [fxImg lomo];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"noise"])
			outImg = [fxImg noise:[[filter objectForKey:@"amount"] doubleValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"polaroid"])
			outImg = [fxImg polaroidish];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"posterize"])
			outImg = [fxImg posterize:[[filter objectForKey:@"amount"] intValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"saturation"])
			outImg = [fxImg saturate:[[filter objectForKey:@"amount"] doubleValue]];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"sepia"])
			outImg = [fxImg sepia];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"sharpen"])
			outImg = [fxImg sharpen];
		
		else if ([[filter objectForKey:@"type"] isEqualToString:@"vignette"])
			outImg = [fxImg vignette];
		
		fxImg = outImg;
	}
	
	return (outImg);
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


+(NSString *)twitterID {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"]);
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
	[[GANTracker sharedTracker] stopTracker];
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	/*
	for (NSString *name in [UIFont familyNames]) {
		NSLog(@"Family name : %@", name);
		for (NSString *font in [UIFont fontNamesForFamilyName:name]) {
			NSLog(@"Font name : %@", font);             
		}
	}
	*/
	
	[defaults setObject:[NSNumber numberWithInt:0] forKey:@"splash_state"];
	[defaults synchronize];
	
	//if ([SNAppDelegate hasNetwork]) {	
		[[SNTwitterCaller sharedInstance] writeProfile];
		
		if (![defaults objectForKey:@"boot_total"]) {
			[defaults setObject:[NSNumber numberWithInt:0] forKey:@"boot_total"];
			[defaults setObject:[NSDate new] forKey:@"install_date"];
			[defaults synchronize];
		
		} else {
			int boot_total = [[defaults objectForKey:@"boot_total"] intValue];
			boot_total++;
			
			[defaults setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
			[defaults synchronize];
			
			int daysSinceInstall = [[NSDate new] timeIntervalSinceDate:[defaults objectForKey:@"install_date"]] / 86400;
			if ([[defaults objectForKey:@"boot_total"] intValue] == kLaunchesUntilRateRequest || daysSinceInstall >= kDaysUntilRateRequest) {
				UIAlertView *alert = [[UIAlertView alloc] 
											 initWithTitle:@"Rate Assembly" 
											 message:@"Why not rate Assembly in the app store!" 
											 delegate:self 
											 cancelButtonTitle:@"Cancel" 
											 otherButtonTitles:@"No Thanks", @"Ask Me Later", nil];
				
				[alert show];
			}
			

			[SNAppDelegate notificationsToggle:YES];
					
			// init Airship launch options
			NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
			[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
					
			// create Airship singleton that's used to talk to Urban Airhship servers, populate AirshipConfig.plist with your info from http://go.urbanairship.com
			[UAirship takeOff:takeOffOptions];
			[[UAPush shared] resetBadge];//zero badge on startup
			[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
		}
		
		[[GANTracker sharedTracker] startTrackerWithAccountID:kAnalyticsAccountId
															dispatchPeriod:kGANDispatchPeriodSec
																	delegate:nil];
		[[GANTracker sharedTracker] setDryRun:!kIsGoogleAnalyticsLive];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:@"/bootup" withError:&error])
			NSLog(@"error in trackPageview");
	
//	} else {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bummer :(" 
//																			 message:@"A network connection is required for Assembly. Please connect and then try again." 
//																			delegate:nil 
//																cancelButtonTitle:@"OK" 
//																otherButtonTitles:nil];
//		[alertView show];
//	}
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *rootNavigationController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		_splashViewController_iPhone = [[SNSplashViewController_iPhone alloc] init];
		
		rootNavigationController = [[UINavigationController alloc] initWithRootViewController:_splashViewController_iPhone];
		[rootNavigationController setNavigationBarHidden:YES];
		
		[self.window setRootViewController:rootNavigationController];
		[self.window setBackgroundColor:[UIColor blackColor]];
		[self.window makeKeyAndVisible];
		
		UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:self.window.frame];
		overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
		[self.window addSubview:overlayImgView];
	
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
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([SNAppDelegate hasNetwork]) {
		[[SNTwitterCaller sharedInstance] writeProfile];
		
		if ([[defaults objectForKey:@"splash_state"] intValue] == 1)
			[_splashViewController_iPhone restart];
	
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bummer :(" 
																			 message:@"A network connection is required for Assembly. Please connect and then try again." 
																			delegate:nil 
																cancelButtonTitle:@"OK" 
																otherButtonTitles:nil];
		[alertView show];
	}
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


#pragma mark - AlertView delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"buttonIndex:[%d]", buttonIndex);
	switch(buttonIndex) {
		case 2:
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"boot_total"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/id284417350?mt=8"]];
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/getassembly"]];
			break;
	}
}



@end
