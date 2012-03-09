//
//  SNAppDelegate.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNChannelGridViewController_iPhone.h"
#import "SNVideoGridViewController_iPad.h"


@class SNViewController;

@interface SNAppDelegate : UIResponder <UIApplicationDelegate> {
	SNVideoGridViewController_iPad *_gridViewController_iPad;
	SNChannelGridViewController_iPhone *_gridViewController_iPhone;
}

@property (strong, nonatomic) UIWindow *window;

#define kServerPath @"http://dev.gullinbursti.cc/projs/simplenews/services"


+(UIFont *)snHelveticaNeueFontRegular;
+(UIFont *)snHelveticaNeueFontBold;
+(UIFont *)snHelveticaNeueFontMedium;

+(void)playMP3:(NSString *)filename;

+(BOOL)hasWiFi;
+(BOOL)hasAirplay;

+(int)minutesAfterDate:(NSDate *)date;
+(int)hoursAfterDate:(NSDate *)date;
+(int)daysAfterDate:(NSDate *)date;

@end
