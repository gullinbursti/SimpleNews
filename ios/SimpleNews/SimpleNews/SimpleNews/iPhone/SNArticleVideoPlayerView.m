//
//  SNArticleVideoPlayerView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.03.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "GANTracker.h"

#import "SNArticleVideoPlayerView.h"
#import "SNAppDelegate.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface SNArticleVideoPlayerView()
-(void)_initPlayer;

-(void)_goPlayPause;
-(void)_goStopVideo;
-(void)_goClose;

-(void)_timerTick;
-(void)_fadeInControls;
-(void)_fadeOutControls;
@end

@implementation SNArticleVideoPlayerView

@synthesize mpc;

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/video/%d", _vo.article_id] withError:&error])
			NSLog(@"error in trackPageview");
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playingChangeCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playbackStateChangedCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateChangedCallback:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_killVideo:) name:@"KILL_VIDEO" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startScrubbing:) name:@"START_VIDEO_SCRUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_stopScrubbing:) name:@"STOP_VIDEO_SCRUB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_ffScrub:) name:@"FF_VIDEO_TIME" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rrScrub:) name:@"RR_VIDEO_TIME" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_enteredFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leftFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
		
		_videoHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_videoHolderView];
		
		_screenshotImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_screenshotImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _vo.video_url]];
		_screenshotImgView.alpha = 0.5;
		
		if (_vo != nil)
			[_videoHolderView addSubview:_screenshotImgView];
		
		_progressBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, _videoHolderView.frame.size.height - 8.0, _videoHolderView.frame.size.width, 8.0)];
		_progressBgImgView.image = [UIImage imageNamed:@"playerPlayHeadBG.png"];
		//[self addSubview:_progressBgImgView];
		
		_progressImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, _videoHolderView.frame.size.height - 8.0, 0.0, 8.0)];
		_progressImgView.image = [UIImage imageNamed:@"playerPlayHeadProgression.png"];
		//[self addSubview:_progressImgView];
		
		MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(270.0, 440.0, 40.0, 20.0)];
		[volumeView setShowsVolumeSlider:NO];
		[volumeView sizeToFit];
		//[self addSubview:volumeView];
		
		_timeSize = [[NSString stringWithFormat:@"%@", @"0:00"] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10.0] constrainedToSize:CGSizeMake(96.0, 10.0) lineBreakMode:UILineBreakModeClip];
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, _videoHolderView.frame.size.height - 18.0, _timeSize.width, _timeSize.height)];
		_timeLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
		_timeLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_timeLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_timeLabel.text = @"0:00";
		//[self addSubview:_timeLabel];
		
		_playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_playButton.frame = CGRectMake((self.frame.size.width * 0.5) - 32.0, (self.frame.size.height * 0.5) - 32.0, 64.0, 64.0);
		_playButton.alpha = 0.0;
		[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[_playButton addTarget:self action:@selector(_goPlayPause) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_playButton];
		
		_pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_pauseButton.frame = CGRectMake((self.frame.size.width * 0.5) - 32.0, (self.frame.size.height * 0.5) - 32.0, 64.0, 64.0);
		_pauseButton.alpha = 0.0;
		[_pauseButton setBackgroundImage:[[UIImage imageNamed:@"pauseButton.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_pauseButton setBackgroundImage:[[UIImage imageNamed:@"pauseButton.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[_pauseButton addTarget:self action:@selector(_goPlayPause) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_pauseButton];
		
		_bufferingImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width * 0.5) - 32.0, (self.frame.size.height * 0.5) - 32.0, 64.0, 64.0)];
		_bufferingImgView.image = [UIImage imageNamed:@"videoBufferingBackground.png"];
		[self addSubview:_bufferingImgView];
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_activityIndicatorView.frame = CGRectMake(16.0, 16.0, 32.0, 32.0);
		[_activityIndicatorView startAnimating];
		[_bufferingImgView addSubview:_activityIndicatorView];
		
		//NSLog(@"YOUTUBE ID:[%@]", _vo.video_url);
		
		if (_vo != nil) {
			_videoInfoRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/get_video_info?html5=1&video_id=%@&eurl=http%3A%2F%2Fshelby.tv%2F&ps=native&el=embedded&hl=en_US", _vo.video_url]]];
			_videoInfoRequest.delegate = self;
			[_videoInfoRequest startAsynchronous];
		}
		
		UITapGestureRecognizer *dblTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_dblTap:)];
		dblTapRecognizer.numberOfTapsRequired = 2;
		[self addGestureRecognizer:dblTapRecognizer];
	}
	
	return (self);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"KILL_VIDEO" object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_VIDEO_SCRUB" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOP_VIDEO_SCRUB" object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FF_VIDEO_TIME" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"RR_VIDEO_TIME" object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
}

-(void)startPlayback {
	[self _initPlayer];
}

-(void)stopPlayback {
	[self _goClose];
}

-(void)reframe:(CGRect)frame {
	self.frame = frame;
	
	CGRect adjFrame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	
	_videoHolderView.frame = adjFrame;
	_screenshotImgView.frame = adjFrame;
	
	_progressBgImgView.frame = CGRectMake(_progressBgImgView.frame.origin.x, _videoHolderView.frame.size.height - 8.0, _videoHolderView.frame.size.width, 8.0);
	_progressImgView.frame = CGRectMake(_progressImgView.frame.origin.x, _videoHolderView.frame.size.height - 8.0, 0.0, 8.0);
	_timeLabel.frame = CGRectMake(_timeLabel.frame.origin.x, _videoHolderView.frame.size.height - 18.0, _timeSize.width, _timeSize.height);
	
	_bufferingImgView.frame = CGRectMake((self.frame.size.width * 0.5) - 32.0, (self.frame.size.height * 0.5) - 32.0, 64.0, 64.0);
	_playButton.frame = CGRectMake((self.frame.size.width * 0.5) - 32.0, (self.frame.size.height * 0.5) - 32.0, 64.0, 64.0);
	_pauseButton.frame = CGRectMake((self.frame.size.width * 0.5) - 32.0, (self.frame.size.height * 0.5) - 32.0, 64.0, 64.0);
}

-(void)_dblTap:(UIGestureRecognizer *)gestureRecognizer {
	//NSLog(@"DBL TAP");
	//
	//[self.mpc setFullscreen:YES animated:YES];
	//self.mpc.controlStyle = MPMovieControlStyleDefault;
}

-(void)_initPlayer {
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_videoURL]];
	self.mpc = mp;
	
	_isFullscreen = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_finishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	self.mpc.controlStyle = MPMovieControlStyleNone;
	self.mpc.view.frame = CGRectMake(0.0, 0.0, _videoHolderView.frame.size.width, 240.0);
	self.mpc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.mpc.shouldAutoplay = YES;
	self.mpc.allowsAirPlay = YES;
	self.mpc.movieSourceType = MPMovieSourceTypeFile;
	
	[_videoHolderView addSubview:self.mpc.view];
	 
	_progressImgView.frame = CGRectMake(_progressImgView.frame.origin.x, _progressImgView.frame.origin.y, 0.0, _progressImgView.frame.size.height);
	_timeSize = [[NSString stringWithFormat:@"%@", @"0:00"] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10.0] constrainedToSize:CGSizeMake(96.0, 10.0) lineBreakMode:UILineBreakModeClip];
	_timeLabel.frame = CGRectMake(0.0, _timeLabel.frame.origin.y, _timeSize.width, _timeSize.height);
	_timeLabel.text = @"0:00";
	
	
	
//	UIImage *thumbImage = [self.mpc thumbnailImageAtTime:10.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
//	if (thumbImage == nil)
//		NSLog(@"NO THUMB!!");
//	
//	else {
//		_screenshotImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
//		_screenshotImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _vo.video_url]];
//		[_videoHolderView addSubview:_screenshotImgView];
//	}
}


#pragma mark - Control handlers
-(void)_goClose {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	_isFinished = YES;
	
	[_hudTimer invalidate];
	_hudTimer = nil;
	
	[_progressTimer invalidate];
	_progressTimer = nil;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_playButton.alpha = 1.0;
		_screenshotImgView.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		if (self.mpc != nil) {
			[self.mpc stop];
			[self.mpc.view removeFromSuperview];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
	}];
}

-(void)_goPlayPause {
	
	if (self.mpc) {
		if (self.mpc.playbackState == MPMoviePlaybackStatePlaying) {
			[self.mpc pause];
			_playButton.alpha = 1.0;
			_pauseButton.alpha = 0.0;
			
		} else if (self.mpc.playbackState == MPMoviePlaybackStatePaused) {
			[self.mpc play];
			_playButton.alpha = 0.0;
			_pauseButton.alpha = 1.0;
		}
		
		_isPaused = (self.mpc.playbackState == MPMoviePlaybackStatePaused);
		
	} else
		[self _initPlayer];
}

-(void)_goStopVideo {
	[self.mpc stop];
}

-(void)_timerTick {
	//NSLog(@"VIDEO POS:[%f/%f]", self.mpc.currentPlaybackTime, self.mpc.duration);
	//_progressImgView.frame = CGRectMake(0.0, _videoHolderView.frame.size.height - 8.0, _videoHolderView.frame.size.width * (self.mpc.currentPlaybackTime / self.mpc.duration), _progressImgView.frame.size.height);
	
	//int hours = (int)self.mpc.currentPlaybackTime / 3600;
	
	NSString *formattedTime = [[NSString alloc] initWithFormat:@"%d:%02d", ((int)(self.mpc.currentPlaybackTime / 60) % 60), ((int)self.mpc.currentPlaybackTime % 60)];
	_timeSize = [formattedTime sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10.0] constrainedToSize:CGSizeMake(96.0, 10.0) lineBreakMode:UILineBreakModeClip];
	_timeLabel.text = formattedTime;
	
	if (_timeSize.width * 0.5 < _progressImgView.frame.size.width && _timeLabel.frame.origin.x < _videoHolderView.frame.size.width - (_timeSize.width + 5.0))
		_timeLabel.frame = CGRectMake(_progressImgView.frame.size.width - (_timeSize.width * 0.5), _videoHolderView.frame.size.height - 18.0, _timeSize.width, _timeSize.height);
}

-(void)toggleControls {
	if (_isControls) {
		[_hudTimer invalidate];
		_hudTimer = nil;
		
		if (self.mpc.playbackState == MPMoviePlaybackStatePlaying)
			[self _fadeOutControls];
				
	} else {
		[self _fadeInControls];
		_hudTimer = [NSTimer scheduledTimerWithTimeInterval:2.33 target:self selector:@selector(_fadeOutControls) userInfo:nil repeats:NO];
	}
}

-(void)_fadeInControls {
	_isControls = YES;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		if (self.mpc.playbackState == MPMoviePlaybackStatePlaying)
			_pauseButton.alpha = 1.0;
		
		else if (self.mpc.playbackState == MPMoviePlaybackStatePaused)
			_playButton.alpha = 1.0;
		
		_progressBgImgView.alpha = 1.0;
		_progressImgView.alpha = 1.0;
		_timeLabel.alpha = 1.0;
	}];	
}

-(void)_fadeOutControls {
	_isControls = NO;
	
	[_hudTimer invalidate];
	_hudTimer = nil;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_playButton.alpha = 0.0;
		_pauseButton.alpha = 0.0;
		_progressBgImgView.alpha = 0.0;
		_progressImgView.alpha = 0.0;
		_timeLabel.alpha = 0.0;
	}];
}

#pragma mark - Notification handlers
-(void)_enteredFullscreen:(NSNotification *)notification {
	NSLog(@"_enteredFullscreen");
	_isFullscreen = YES;
}

-(void)_leftFullscreen:(NSNotification *)notification {
	NSLog(@"_leftFullscreen");
	_isFullscreen = NO;
	self.mpc.controlStyle = MPMovieControlStyleNone;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_playButton.alpha = 1.0;
		_screenshotImgView.alpha = 1.0;
	}];
}

-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----[STARTED PLAYBACK]----");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	
	_isFinished = NO;
	_isPaused = NO;
	_isStalled = NO;
	
	[_progressTimer invalidate];
	_progressTimer = nil;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bufferingImgView.hidden = NO;
		_bufferingImgView.alpha = 1.0;
	}];
		
	[self _fadeOutControls];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_STARTED" object:nil];
	_progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerTick) userInfo:nil repeats:YES];
}

-(void)_finishedCallback:(NSNotification *)notification {
	NSLog(@"----[FINISHED PLAYBACK](%f, %f)----", self.mpc.currentPlaybackTime, self.mpc.duration);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	_isFinished = YES;
	
	[_progressTimer invalidate];
	_progressTimer = nil;
	
	[_hudTimer invalidate];
	_hudTimer = nil;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_playButton.alpha = 0.0;
		_screenshotImgView.alpha = 1.0;
		[_bufferingImgView removeFromSuperview];
		
	} completion:^(BOOL finished) {
		[self.mpc.view removeFromSuperview];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
	}];
}

-(void)_loadStateChangedCallback:(NSNotification *)notification {
	NSLog(@"----[LOAD STATE CHANGED[%d]](%f, %f)----", self.mpc.loadState, self.mpc.naturalSize.width, self.mpc.naturalSize.height);
	
	switch (self.mpc.loadState) {
		case MPMovieLoadStatePlayable:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_DURATION" object:[NSNumber numberWithFloat:self.mpc.duration]];
			break;
			
		case 3:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_SIZE" object:[NSNumber numberWithFloat:self.mpc.naturalSize.height]];
			
			if (_isStalled) {
				_isStalled = NO;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_RESUMED" object:nil];	
			}
			break;
			
		case 5:
			_isStalled = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_STALLED" object:nil];
			break;
	}
}

-(void)_playbackStateChangedCallback:(NSNotification *)notification {
	NSLog(@"----[PLAYBACK STATE CHANGED[%d]]----", self.mpc.playbackState);	
	
	switch (self.mpc.playbackState) {
		case MPMoviePlaybackStateStopped:
			if (_isFullscreen) {
				[self.mpc setFullscreen:NO animated:YES];
				self.mpc.controlStyle = MPMovieControlStyleNone;
			}
			
			break;
			
		case MPMoviePlaybackStatePlaying:
			[UIView animateWithDuration:0.33 animations:^(void) {
				_screenshotImgView.alpha = 0.0;
				_bufferingImgView.alpha = 0.0;
				
			} completion:^(BOOL finished) {
				_bufferingImgView.hidden = YES;
			}];
			break;
	}
}


-(void)_playingChangeCallback:(NSNotification *)notification {
	NSLog(@"----[PLAYING CHANGED[%d]]----", self.mpc.playbackState);
}

-(void)_killVideo:(NSNotification *)notification {
	[self.mpc stop];
	[self _goClose];
}

-(void)_startScrubbing:(NSNotification *)notification {
	NSLog(@"----START SCRUBBING----");
	
	if (self.mpc.playbackState == MPMoviePlaybackStatePlaying)
		[self.mpc pause];
}

-(void)_stopScrubbing:(NSNotification *)notification {
	NSLog(@"----STOP SCRUBBING----");
	
	[self.mpc play];
}

-(void)_ffScrub:(NSNotification *)notification {
	NSLog(@"----FF SCRUB----");
	
	self.mpc.currentPlaybackTime++;
}

-(void)_rrScrub:(NSNotification *)notification {
	NSLog(@"----RR SCRUB----");
	
	self.mpc.currentPlaybackTime--;
}


#pragma mark - HTTPRequest Delegates
-(void)requestStarted:(ASIHTTPRequest *)request {
	//NSLog(@"requestStarted");
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
	//NSLog(@"didReceiveResponseHeaders:\n%@", responseHeaders);
}

-(void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
	NSLog(@"willRedirectToURL:\n%@", newURL);
}

-(void)requestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"requestFinished:\n%@", [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding]);
	//NSString *videoStreamMap = @"url_encoded_fmt_stream_map= ... &tmi=1";
	
	NSString *videoInfo = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//NSLog(@"%@", videoInfo);
	
	NSRange errorRange = [videoInfo rangeOfString:@"status=fail"];
	NSLog(@"errorRange.location[%d] .length[%d] -- (%d)", errorRange.location, errorRange.length, [videoInfo length]);
	
	if (errorRange.length == 0 || errorRange.location > [videoInfo length]) {
		NSRange prefixRange = [videoInfo rangeOfString:@"url_encoded_fmt_stream_map=url="];
		NSRange suffixRange = [videoInfo rangeOfString:@"&tmi=1"];
		NSLog(@"(%d) -- [%@][%@]", [videoInfo length], NSStringFromRange(prefixRange), NSStringFromRange(suffixRange));
		
		if (suffixRange.location < prefixRange.location)
			suffixRange = [videoInfo rangeOfString:@"&no_get_video_log=1"];
		
		if (suffixRange.location < prefixRange.location) {
			[self _goClose];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_FULLSCREEN_MEDIA" object:nil];
		
		} else {	
			//NSString *streamMap = [videoInfo substringWithRange:NSMakeRange(prefixRange.location + prefixRange.length, suffixRange.location - (prefixRange.location + prefixRange.length))];
			//NSLog(@"%@", streamMap);
			
			NSArray *mp4Videos = [[videoInfo substringWithRange:NSMakeRange(prefixRange.location + prefixRange.length, suffixRange.location - (prefixRange.location + prefixRange.length))] componentsSeparatedByString:@"url="];
			NSMutableDictionary *videoURLs = [NSMutableDictionary new];
			
			for (NSString *url in mp4Videos) {
				if ([url rangeOfString:@"type=video%2Fmp4%3B"].length > 0) {
					
					if ([url rangeOfString:@"quality=hd720"].length > 0)
						[videoURLs setObject:[[url substringWithRange:NSMakeRange(0, [url rangeOfString:@"quality=hd720"].location - 1)] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"hd"];
					
					if ([url rangeOfString:@"quality=medium"].length > 0)
						[videoURLs setObject:[[url substringWithRange:NSMakeRange(0, [url rangeOfString:@"quality=medium"].location - 1)] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"sd"];
					
					//NSLog(@"VIDEOS:\n\n[======================================================]\n%@\n[======================================================]\n", url);
				}
			}
			
			NSString *videoURL = [videoURLs objectForKey:@"sd"];
			_videoURL = videoURL;
			
			//if ([videoURLs objectForKey:@"hd"])
			//	videoURL = [videoURLs objectForKey:@"hd"];
			
			NSLog(@"%@", videoURLs);
		}
	
	} else {
		[self _goClose];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_FULLSCREEN_MEDIA" object:nil];
	}
		
	//NSLog(@"%@", [@"http%3A%2F%2Fo-o.preferred.comcast-lax1.v21.lscache4.c.youtube.com%2Fvideoplayback%3Fupn%3DNjE0NjE0NjY0NzY4NDEzNDA5OA%253D%253D%26sparams%3Dcp%252Cid%252Cip%252Cipbits%252Citag%252Cratebypass%252Csource%252Cupn%252Cexpire%26fexp%3D902904%252C904820%252C901601%26itag%3D37%26ip%3D98.0.0.0%26signature%3DAC36EF98C4CFECF8E5BFEA29EE9A009A40D18106.4BE3C83EE174FEC7EEDC72303CD49FCBE4F9F150%26sver%3D3%26ratebypass%3Dyes%26source%3Dyoutube%26expire%3D1332511088%26key%3Dyt1%26ipbits%3D8%26cp%3DU0hSR1VMT19NUkNOMl9NRlNBOjNqczdGMmdmd2pJ%26id%3Dd5783ada74dc476c" stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
}

-(void)requestRedirected:(ASIHTTPRequest *)request {
	NSLog(@"requestRedirected");
}

@end
