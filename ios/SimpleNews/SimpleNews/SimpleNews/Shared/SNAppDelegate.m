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

static NSString * kFacebookAppId = @"316539575066102";
NSString * const kOJProfileInfoKey = @"ProfileInfo";

@implementation SNAppDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;

+(void)writeFollowers:(NSString *)followers {
	[[NSUserDefaults standardUserDefaults] setObject:followers forKey:@"followers"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)subscribedFollowers {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"followers"]);
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

+(UIImage *)imageWithView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (img);
}


+(NSDictionary *)profileForUser {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kOJProfileInfoKey];
}

+(BOOL)isProfileInfoAvailable {
	return ([self profileForUser] != nil);
}

+(void)setUserProfile:(NSDictionary *)profile {
	if (profile != nil)
		[[NSUserDefaults standardUserDefaults] setObject:profile forKey:kOJProfileInfoKey];
	
	else
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kOJProfileInfoKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}



-(void)dealloc {
	[_window release];
	
	[super dealloc];
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"airplay_enabled"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"FBAccessTokenKey"];
	[defaults removeObjectForKey:@"FBExpirationDateKey"];
	[defaults synchronize];
	
	
	//if (![SNAppDelegate subscribedFollowers])
		[SNAppDelegate writeFollowers:@""];
	
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	
	
	_facebookPermissions = [[NSArray arrayWithObjects:
									 @"read_stream", @"publish_stream", @"offline_access", 
									 @"user_relationships", 
									 @"user_birthday", 
									 @"user_work_history", 
									 @"user_education_history",
									 @"user_location",
									 nil] retain];
	
	UINavigationController *rootNavigationController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		//_splashViewController_iPhone = [[SNSplashViewController_iPhone alloc] init];
		//rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_splashViewController_iPhone] autorelease];
		
		_gridViewController_iPhone = [[SNFollowerGridViewController_iPhone alloc] init];
		rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_gridViewController_iPhone] autorelease];
		
		
		// Initialize Facebook
		_facebook = [[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:self];
		
		// Check and retrieve authorization information
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
			_facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
			_facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
		}
		
		[rootNavigationController setNavigationBarHidden:YES];
		[self.window setRootViewController:rootNavigationController];
		[self.window makeKeyAndVisible];
		
		
		// Check App ID:
		// This is really a warning for the developer, this should not
		// happen in a completed app
		if (!kFacebookAppId) {
			UIAlertView *alertView = [[UIAlertView alloc]
											  initWithTitle:@"Setup Error"
											  message:@"Missing app ID. You cannot run the app until you provide this in the code."
											  delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil,
											  nil];
			[alertView show];
			[alertView release];
		} else {
			// Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
			// be opened, doing a simple check without local app id factored in here
			NSString *url = [NSString stringWithFormat:@"fb%@://authorize",kFacebookAppId];
			BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
			NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
			if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
				 ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
					NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
					if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
						 ([aBundleURLSchemes count] > 0)) {
						NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
						if ([scheme isKindOfClass:[NSString class]] &&
							 [url hasPrefix:scheme]) {
							bSchemeInPlist = YES;
						}
					}
            }
			}
			// Check if the authorization callback will work
			BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
			if (!bSchemeInPlist || !bCanOpenUrl) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Setup Error"
                                      message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil,
                                      nil];
            //[alertView show];
            [alertView release];
			}
		}
		
		
		SNSplashViewController_iPhone *splashViewController = [[[SNSplashViewController_iPhone alloc] init] autorelease];
		UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:splashViewController] autorelease];
		
		[navigationController setNavigationBarHidden:YES];
		[rootNavigationController presentModalViewController:navigationController animated:NO];
		
		// Show a splash screen immediately
		//SNSplashViewController_iPhone *splashViewController = [[[SNSplashViewController_iPhone alloc] init] autorelease];
		//UINavigationController *splashNavigationController = [[[UINavigationController alloc] initWithRootViewController:splashViewController] autorelease];
		//[splashNavigationController setNavigationBarHidden:YES animated:NO];
		//[rootNavigationController pushViewController:splashViewController animated:NO];
	
	} else {
		_gridViewController_iPad = [[SNVideoGridViewController_iPad alloc] init];
		rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:_gridViewController_iPad] autorelease];
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
	[_facebook extendAccessTokenIfNeeded];
}

/**
 Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
 **/
- (void)applicationWillTerminate:(UIApplication *)application {
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [_facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [_facebook handleOpenURL:url]; 
}


- (void)confirmSignUpWithProfile:(NSDictionary *)profile {
	[SNAppDelegate setUserProfile:profile];
	//[[OJGraphCaller sharedInstance] postActivity:@"install" withObject:@"odd_job"];
}

- (void)signOut {
}



#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
	NSLog(@"LOGGED IN");
	
	//SNAppDelegate *delegate = (SNAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
	[defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
	[defaults synchronize];
	
	
	//[pendingApiCallsController userDidGrantPermission];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
	NSLog(@"token extended");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
	[defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
	[defaults synchronize];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
	//[pendingApiCallsController userDidNotGrantPermission];
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
	//pendingApiCallsController = nil;
	
	// Remove saved authorization information if it exists and it is
	// ok to clear it (logout, session invalid, app unauthorized)
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"FBAccessTokenKey"];
	[defaults removeObjectForKey:@"FBExpirationDateKey"];
	[defaults synchronize];
	
	//	[self showLoggedOut];
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
	UIAlertView *alertView = [[UIAlertView alloc]
									  initWithTitle:@"Auth Exception"
									  message:@"Your session has expired."
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil,
									  nil];
	[alertView show];
	[alertView release];
	[self fbDidLogout];
}


@end
