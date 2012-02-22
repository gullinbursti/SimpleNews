//
//  SNSplashViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNSplashViewController_iPhone : UIViewController {
	NSMutableArray *_photoSlides;
	
	NSTimer *_timer;
	int _timerCount;
	
	UIImageView *_introImageView;
	UIImageView *_outroImageView;
}

@end
