//
//  SNVideoPlayerView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNVideoPlayerView_iPhone : UIView <UIWebViewDelegate> {
	UIWebView *_webView;
	
	NSTimer *_timer;
	BOOL _isFinished;
	BOOL _isPaused;
	float _duration; 
}

@end
