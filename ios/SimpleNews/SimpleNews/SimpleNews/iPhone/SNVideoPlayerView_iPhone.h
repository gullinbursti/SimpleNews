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
#import "SNArticleFollowerInfoView_iPhone.h"
#import "ASIHTTPRequest.h"

@interface SNVideoPlayerView_iPhone : UIView <ASIHTTPRequestDelegate> {
	
	BOOL _isFullscreen;
	BOOL _isStalled;
	BOOL _isPaused;
	BOOL _isFinished;
	
	ASIHTTPRequest *_videoInfoRequest;
	NSTimer *_timer;
	
	SNArticleVO *_vo;
	SNArticleFollowerInfoView_iPhone *_articleFollowerView;
	
	UIImageView *_bgImgView;
	UIView *_videoHolderView;
	UIView *_progressView;
	UILabel *_timeLabel;
	CGSize _timeSize;
	
	UIButton *_playButton;
}

@property (nonatomic, retain) MPMoviePlayerController *mpc;

-(void)changeArticleVO:(SNArticleVO *)vo;

@end
