//
//  SNSplashViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNSplashViewController_iPhone : UIViewController {
	NSTimer *_frameTimer;
	int _frameIndex;
	UIImageView *_logoImgView;
}

@end
