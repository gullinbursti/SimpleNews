//
//  SNAppDelegate.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSplashViewController_iPhone.h"
#import "SNFollowerGridViewController_iPhone.h"
#import "SNVideoGridViewController_iPad.h"

#import "Facebook.h"


@class SNViewController;

@interface SNAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate> {
	SNSplashViewController_iPhone *_splashViewController_iPhone;
	
	SNVideoGridViewController_iPad *_gridViewController_iPad;
	SNFollowerGridViewController_iPhone *_gridViewController_iPhone;
	
	Facebook *_facebook;
	NSArray *_facebookPermissions;
	void (^_facebookAuthorizationHandler)(BOOL didLogIn);
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;

#define kServerPath @"http://dev.gullinbursti.cc/projs/simplenews/services"

//-(void)authorizeFacebookWithHandler:(void (^)(BOOL didLogIn))handler;
-(void)confirmSignUpWithProfile:(NSDictionary *)profile;
+(BOOL)isProfileInfoAvailable;
+(NSDictionary *)profileForUser;
+(void)setUserProfile:(NSDictionary *)profile;


+(void)writeFollowers:(NSString *)followers;
+(NSString *)subscribedFollowers;


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

+(UIImage *)imageWithView:(UIView *)view;

+(int)minutesAfterDate:(NSDate *)date;
+(int)hoursAfterDate:(NSDate *)date;
+(int)daysAfterDate:(NSDate *)date;

@end
