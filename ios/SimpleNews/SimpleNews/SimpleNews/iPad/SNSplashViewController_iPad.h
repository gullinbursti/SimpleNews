//
//  SNSplashViewController_iPad.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.02.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNLogoView.h"
#import "SNNoAirplayView_iPhone.h"

@interface SNSplashViewController_iPad : UIViewController {
	NSMutableArray *_photoSlides;
	
	NSTimer *_timer;
	int _timerCount;
	
	UIImageView *_introImageView;
	UIImageView *_outroImageView;
	
	UIView *_holderView;
	UIView *_progressView;
	
	SNLogoView *_logoView;
	SNNoAirplayView_iPhone *_noAirplayView;
}

@end
