//
//  SNAppDelegate.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNViewController;

@interface SNAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) NSMutableArray *windows;

#define kServerPath @"http://dev.gullinbursti.cc/projs/simplenews/services"

-(UIWindow *)createWindowForScreen:(UIScreen *)screen;
-(void) addViewController:(UIViewController *)controller toWindow:(UIWindow *)window;

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
