//
//  SNVideoPlayerView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SNArticleVO.h"
#import "ASIHTTPRequest.h"

@interface SNVideoPlayerView_iPhone : UIView <UIWebViewDelegate, ASIHTTPRequestDelegate> {
	UIWebView *_webView;
	
	BOOL _isFinished;
	BOOL _isPaused;
	float _duration;
	
	BOOL _isFirstPlay;
	BOOL _isFullscreen;
	
	UIView *_overlayView;
	SNArticleVO *_vo;
	
	ASIHTTPRequest *_videoInfoRequest;
	UIView *_videoHolderView;
	
	
	NSTimer *_timer;
	BOOL _isFirst;
	BOOL _isStalled;
}

@property (nonatomic, retain) MPMoviePlayerController *mpc;

-(void)changeArticleVO:(SNArticleVO *)vo;

@end
