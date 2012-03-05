//
//  SNVideoPlayerViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SNVideoItemVO.h"
#import "EGOImageView.h"

#import "MBProgressHUD.h"

@interface SNVideoPlayerViewController_iPhone : UIViewController {
	
	NSTimer *_timer;
	BOOL _isFinished;
	BOOL _isPaused;
	BOOL _isFirst;
	float _duration;
	
	UIWebView *_webView;
	SNVideoItemVO *_vo;
	EGOImageView *_overlayImgView;
	
	MBProgressHUD *_hud;
	
	NSString *_videoURL;
	
	UIView *_videoHolderView;
	UIView *_overlayHolderView;
}


@property (nonatomic, retain) MPMoviePlayerController *mpc;


@end
