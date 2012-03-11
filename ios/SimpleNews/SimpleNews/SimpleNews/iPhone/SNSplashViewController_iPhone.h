//
//  SNSplashViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNSplashHighlightView.h"

@interface SNSplashViewController_iPhone : UIViewController {
	UIImageView *_bgImgView;
	SNSplashHighlightView *_highlightView;
	
	NSTimer *_timer;
	int _cnt;
}

@end
