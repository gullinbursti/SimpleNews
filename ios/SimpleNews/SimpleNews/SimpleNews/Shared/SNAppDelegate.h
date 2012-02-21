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

//@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) SNViewController *viewController;

-(UIWindow *)createWindowForScreen:(UIScreen *)screen;
-(void) addViewController:(UIViewController *)controller toWindow:(UIWindow *)window;

+(UIFont *)snHelveticaFontRegular;
+(UIFont *)snHelveticaFontBold;
+(UIFont *)snHelveticaFontItalic;
+(UIFont *)snHelveticaFontBoldItalic;

@end
