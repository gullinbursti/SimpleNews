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

#import "Facebook.h"
#import "UAPushNotificationHandler.h"


@class SNViewController;

@interface SNAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBRequestDelegate, UAPushNotificationDelegate> {
	SNSplashViewController_iPhone *_splashViewController_iPhone;
	
	SNRootViewController_iPhone *_rootViewController_iPhone;
	
	Facebook *facebook;
	NSArray *userPermissions;
}

#define kServerPath @"http://dev.gullinbursti.cc/projs/simplenews/services"

+(SNAppDelegate *)sharedInstance;

+(void)writeFBProfile:(NSDictionary *)profile;
+(NSDictionary *)fbProfile;

+(void)writeUserProfile:(NSDictionary *)userInfo;
+(NSDictionary *)profileForUser;

+(void)writeDeviceToken:(NSString *)token;
+(NSString *)deviceToken;

+(void)twitterToggle:(BOOL)isSignedIn;
+(BOOL)twitterEnabled;
+(NSString *)twitterHandle;


+(void)writeInfluencers:(NSString *)influencers;
+(NSString *)subscribedInfluencers;


+(UIFont *)snHelveticaNeueFontRegular;
+(UIFont *)snHelveticaNeueFontBold;
+(UIFont *)snHelveticaNeueFontMedium;

+(UIFont *)snAllerFontRegular;
+(UIFont *)snAllerFontBold;
+(UIFont *)snAllerFontItalic;
+(UIFont *)snAllerFontBoldItalic;


+(void)playMP3:(NSString *)filename;

+(BOOL)hasWiFi;
+(BOOL)hasAirplay;

+(void)notificationsToggle:(BOOL)isOn;
+(BOOL)notificationsEnabled;

+(int)minutesAfterDate:(NSDate *)date;
+(int)hoursAfterDate:(NSDate *)date;
+(int)daysAfterDate:(NSDate *)date;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSArray *userPermissions;

@end
