//
//  SNVideoPlayerViewControlller_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SNArticleVO.h"
#import "SNArticleFollowerInfoView_iPhone.h"
#import "ASIHTTPRequest.h"

@interface SNVideoPlayerViewControlller_iPhone : UIViewController <ASIHTTPRequestDelegate> {
	
	BOOL _isFullscreen;
	BOOL _isStalled;
	BOOL _isPaused;
	BOOL _isFinished;
	BOOL _isFlipped;
	BOOL _isControls;
	
	ASIHTTPRequest *_videoInfoRequest;
	NSTimer *_progressTimer;
	NSTimer *_hudTimer;
	
	SNArticleVO *_vo;
	SNArticleFollowerInfoView_iPhone *_articleFollowerView;
	
	UIImageView *_bgImgView;
	UIView *_videoHolderView;
	UIImageView *_progressBgImgView;
	UIImageView *_progressImgView;
	UILabel *_timeLabel;
	UIButton *_closeButton;
	CGSize _timeSize;
	
	UIButton *_playButton;
	UIButton *_pauseButton;
}

@property (nonatomic, retain) MPMoviePlayerController *mpc;

-(void)changeArticleVO:(SNArticleVO *)vo;

@end
