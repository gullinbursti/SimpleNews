//
//  SNArticleVideoPlayerView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SNArticleVO.h"
#import "ASIHTTPRequest.h"
#import "EGOImageView.h"

@interface SNArticleVideoPlayerView_iPhone : UIView <UIGestureRecognizerDelegate, ASIHTTPRequestDelegate> {
	
	BOOL _isFullscreen;
	BOOL _isStalled;
	BOOL _isPaused;
	BOOL _isFinished;
	BOOL _isControls;
	
	ASIHTTPRequest *_videoInfoRequest;
	NSTimer *_progressTimer;
	NSTimer *_hudTimer;
	
	SNArticleVO *_vo;
	
	UIView *_videoHolderView;
	UIImageView *_progressBgImgView;
	UIImageView *_progressImgView;
	UILabel *_timeLabel;
	CGSize _timeSize;
	UIImageView *_bufferingImgView;
	
	EGOImageView *_screenshotImgView;
	UIButton *_playButton;
	UIButton *_pauseButton;
	
	NSString *_videoURL;
}

@property (nonatomic, retain) MPMoviePlayerController *mpc;

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;
-(void)startPlayback;
-(void)stopPlayback;
-(void)toggleControls;
-(void)reframe:(CGRect)frame;

@end
