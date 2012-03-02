//
//  SNActiveListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "EGOImageView.h"

@interface SNActiveListViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, UIWebViewDelegate> {
	NSMutableArray *_items;
	
	UIView *_progressBar;
	UILabel *_titleLabel;
	
	EGOImageView *_currImgView;
	EGOImageView *_nextImgView;
	
	UIButton *_playPauseButton;
	BOOL _isPaused;
	BOOL _isSrubbing;
	float _currTime;
	float _duration;
	
	NSTimer *_scrubTimer;
}

@end
