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


@class SNViewController;

@interface SNAppDelegate : UIResponder <UIApplicationDelegate> {
	SNSplashViewController_iPhone *_splashViewController_iPhone;
	
	SNVideoGridViewController_iPad *_gridViewController_iPad;
	SNFollowerGridViewController_iPhone *_gridViewController_iPhone;
}

@property (strong, nonatomic) UIWindow *window;

#define kServerPath @"http://dev.gullinbursti.cc/projs/simplenews/services"


+(UIFont *)snHelveticaNeueFontRegular;
+(UIFont *)snHelveticaNeueFontBold;
+(UIFont *)snHelveticaNeueFontMedium;

+(void)playMP3:(NSString *)filename;

+(BOOL)hasWiFi;
+(BOOL)hasAirplay;

+(UIImage *)imageWithView:(UIView *)view;

+(int)minutesAfterDate:(NSDate *)date;
+(int)hoursAfterDate:(NSDate *)date;
+(int)daysAfterDate:(NSDate *)date;

@end
