//
//  SNAppDelegate.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSplashViewController_iPhone.h"

#import "SNRootViewController_iPhone.h"
#import "UAPushNotificationHandler.h"

#import "ImageFilter.h"


@class SNViewController;

@interface SNAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
	SNSplashViewController_iPhone *_splashViewController_iPhone;
	
	SNRootViewController_iPhone *_rootViewController_iPhone;
}

//#define kServerPath @"http://dev.gullinbursti-creations.com/simplenews/services"
//#define kServerPath @"http://ec2-23-20-197-174.compute-1.amazonaws.com/services"
#define kServerPath @"http://107.20.161.159/services"
#define kTweetInvite @"@%@ would like you to check out @getAssembly Get it now! http://bit.ly/KPSkKm"
#define kPrivacyPage @"http://107.20.161.159/privacy_policy.htm"
#define kLiveTweet NO

+(SNAppDelegate *)sharedInstance;

+(void)writeUserProfile:(NSDictionary *)userInfo;
+(NSDictionary *)profileForUser;

+(void)writeDeviceToken:(NSString *)token;
+(NSString *)deviceToken;


+(void)twitterToggle:(BOOL)isSignedIn;
+(BOOL)twitterEnabled;
+(NSString *)twitterID;
+(NSString *)twitterHandle;
+(NSString *)twitterAvatar;


+(UIFont *)snHelveticaNeueFontRegular;
+(UIFont *)snHelveticaNeueFontBold;
+(UIFont *)snHelveticaNeueFontMedium;

+(UIFont *)snAllerFontRegular;
+(UIFont *)snAllerFontBold;
+(UIFont *)snAllerFontItalic;
+(UIFont *)snAllerFontBoldItalic;

+(UIColor *)snLineColor;
+(UIColor *)snHeaderColor;
+(UIColor *)snLinkColor;

+(UIColor *)snDebugRedColor;
+(UIColor *)snDebugGreenColor;
+(UIColor *)snDebugBlueColor;

+(void)playMP3:(NSString *)filename;

+(BOOL)hasNetwork;
+(BOOL)hasAirplay;

+(void)notificationsToggle:(BOOL)isOn;
+(BOOL)notificationsEnabled;

+(int)secondsAfterDate:(NSDate *)date;
+(int)minutesAfterDate:(NSDate *)date;
+(int)hoursAfterDate:(NSDate *)date;
+(int)daysAfterDate:(NSDate *)date;


+ (void)openWithAppStore:(NSString *)url;
+(UIImage *)imageWithFilters:(UIImage *)srcImg filter:(NSDictionary *)fx;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSArray *userPermissions;

@end
