//
//  SNArticleVideoPlayerViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>

@interface SNArticleVideoPlayerViewController_iPhone : UIViewController <UIWebViewDelegate, UITextFieldDelegate> {
	UIWebView *_webView;
	
	NSTimer *_timer;
	BOOL _isFinished;
	BOOL _isPaused;
	float _duration;
	
	BOOL _isFullscreen;
	
	UIView *_overlayView;
}

@end
