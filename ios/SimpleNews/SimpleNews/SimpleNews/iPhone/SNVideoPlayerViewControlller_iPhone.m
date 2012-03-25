//
//  SNVideoPlayerViewControlller_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerViewControlller_iPhone.h"
#import "SNAppDelegate.h"
#import "SNArticleFollowerInfoView_iPhone.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface SNVideoPlayerViewControlller_iPhone()
-(void)_goPlayPause;
-(void)_goStopVideo;
-(void)_timerTick;
@end

@implementation SNVideoPlayerViewControlller_iPhone

@synthesize mpc;

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playingChangeCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playbackStateChangedCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateChangedCallback:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startScrubbing:) name:@"START_VIDEO_SCRUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_stopScrubbing:) name:@"STOP_VIDEO_SCRUB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_ffScrub:) name:@"FF_VIDEO_TIME" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rrScrub:) name:@"RR_VIDEO_TIME" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_enteredFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leftFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
		
		_isFlipped = NO;
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_VIDEO_SCRUB" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOP_VIDEO_SCRUB" object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FF_VIDEO_TIME" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"RR_VIDEO_TIME" object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
	
	//[_videoInfoRequest release];
	[_bgImgView release];
	//[_videoHolderView release];
	[_progressView release];
	[_timeLabel release];
	
	[super dealloc];
}


#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	_bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	_bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:_bgImgView];
	
	_videoHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 150.0, self.view.frame.size.width, 185.0)];
	[_videoHolderView setBackgroundColor:[UIColor colorWithWhite:0.204 alpha:1.0]];
	_videoHolderView.alpha = 0.0;
	[self.view addSubview:_videoHolderView];
	
	_backButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	_backButton.frame = CGRectMake(250.0, 42.0, 64.0, 34.0);
	[_backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[_backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	_backButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	_backButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	_backButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	_backButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[_backButton setTitle:@"Done" forState:UIControlStateNormal];
	[_backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_backButton];
	
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:CGRectMake(140.0, 300.0, 40.0, 20.0)] autorelease];
	[volumeView setShowsVolumeSlider:NO];
	[volumeView sizeToFit];
	[self.view addSubview:volumeView];
	
	_progressView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 180.0, self.view.frame.size.width, 5.0)];
	[_progressView setBackgroundColor:[UIColor colorWithWhite:0.408 alpha:1.0]];
	[_videoHolderView addSubview:_progressView];
	
	_timeSize = [[NSString stringWithFormat:@"%@", @"0:00"] sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:10.0] constrainedToSize:CGSizeMake(96.0, 10.0) lineBreakMode:UILineBreakModeClip];
	_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 186.0, _timeSize.width, _timeSize.height)];
	_timeLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:10];
	_timeLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	_timeLabel.backgroundColor = [UIColor clearColor];
	_timeLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	_timeLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	_timeLabel.text = @"0:00";
	[_videoHolderView addSubview:_timeLabel];
	
	UIImageView *playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 84.0, 84.0)];
	playImgView.image = [UIImage imageNamed:@"playIcon.png"];
	
	_playButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	_playButton.frame = CGRectMake(121.0, 198.0, 84.0, 84.0);
	[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	[_playButton addTarget:self action:@selector(_goPlayPause) forControlEvents:UIControlEventTouchUpInside];
	[_playButton addSubview:playImgView];
	[self.view addSubview:_playButton];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}


-(void)viewDidUnload {
	[super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {      
		_isFlipped = NO;
		
		_bgImgView.transform = CGAffineTransformIdentity;
		_bgImgView.transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
		_bgImgView.bounds = CGRectMake(0.0, 0.0, 320.0, 480.0);
		_backButton.frame = CGRectMake(250.0, 42.0, 64.0, 34.0);
		
		_videoHolderView.frame = CGRectMake(0.0, 150.0, 320.0, 185.0);
		self.mpc.view.frame = CGRectMake(0.0, 0.0, 320.0, 180.0);
		_playButton.frame = CGRectMake(121.0, 198.0, 84.0, 84.0);
			
	} else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		_isFlipped = YES;
		
		_bgImgView.transform = CGAffineTransformIdentity;
		_bgImgView.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
		_bgImgView.bounds = CGRectMake(0.0, 0.0, 480.0, 320.0);
		_backButton.frame = CGRectMake(410.0, 42.0, 64.0, 34.0);
		
		_videoHolderView.frame = CGRectMake(0.0, 12.0, 480.0, 275.0);
		self.mpc.view.frame = CGRectMake(0.0, 0.0, 480.0, 270.0);
		_playButton.frame = CGRectMake(198.0, 121.0, 84.0, 84.0);
		
		//480x270
	}
	
	return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}



-(void)changeArticleVO:(SNArticleVO *)vo {
	_vo = vo;
	_isFullscreen = NO;
	
	NSLog(@"YOUTUBE ID:[%@]", _vo.video_url);
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 50.0)] autorelease];
	[self.view addSubview:headerView];
	
	_articleFollowerView = [[[SNArticleFollowerInfoView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 90.0) articleVO:_vo] autorelease];
	[headerView addSubview:_articleFollowerView];
	
	_videoInfoRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/get_video_info?html5=1&video_id=%@&eurl=http%3A%2F%2Fshelby.tv%2F&ps=native&el=embedded&hl=en_US", _vo.video_url]]];
	_videoInfoRequest.delegate = self;
	[_videoInfoRequest startAsynchronous];
}


#pragma mark - Control handlers
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	[self _goStopVideo];
	_isFinished = YES;
	
	[_timer invalidate];
	_timer = nil;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_playButton.alpha = 0.0;
		_videoHolderView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		[_articleFollowerView removeFromSuperview];
		[self.mpc.view removeFromSuperview];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
		[self dismissViewControllerAnimated:NO completion:nil];
	}];
}

-(void)_goPlayPause {
	if (self.mpc.playbackState == MPMoviePlaybackStatePlaying) {
		[self.mpc pause];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_playButton.alpha = 1.0;
		}];
		
	} else if (self.mpc.playbackState == MPMoviePlaybackStatePaused) {
		[self.mpc play];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_playButton.alpha = 0.0;
		}];
	}
	
	_isPaused = (self.mpc.playbackState == MPMoviePlaybackStatePaused);
}

-(void)_goStopVideo {
	[self.mpc stop];
}

-(void)_timerTick {
	//NSLog(@"VIDEO POS:[%f/%f]", self.mpc.currentPlaybackTime, self.mpc.duration);
	
	if (!_isFlipped)
		_progressView.frame = CGRectMake(_progressView.frame.origin.x, 180.0, 320.0 * (self.mpc.currentPlaybackTime / self.mpc.duration), _progressView.frame.size.height);
	
	else
		_progressView.frame = CGRectMake(_progressView.frame.origin.x, 270.0, 480.0 * (self.mpc.currentPlaybackTime / self.mpc.duration), _progressView.frame.size.height);
	
	//int hours = (int)self.mpc.currentPlaybackTime / 3600;
	
	NSString *formattedTime = [[[NSString alloc] initWithFormat:@"%d:%02d", ((int)(self.mpc.currentPlaybackTime / 60) % 60), ((int)self.mpc.currentPlaybackTime % 60)] autorelease];
	_timeSize = [formattedTime sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:10.0] constrainedToSize:CGSizeMake(96.0, 10.0) lineBreakMode:UILineBreakModeClip];
	_timeLabel.text = formattedTime;
	
	if (_timeSize.width * 0.5 < _progressView.frame.size.width) {
		if (!_isFlipped)
			_timeLabel.frame = CGRectMake(_progressView.frame.size.width - (_timeSize.width * 0.5), 186.0, _timeSize.width, _timeSize.height);
		
		else
			_timeLabel.frame = CGRectMake(_progressView.frame.size.width - (_timeSize.width * 0.5), 276.0, _timeSize.width, _timeSize.height);
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	//NSLog(@"TOUCHED SELF:%d", [touch view] == self);
	//NSLog(@"TOUCHED PLAYER:%d", [touch view] == self.mpc.view);
	//NSLog(@"TOUCHED HOLDER:%d", [touch view] == _videoHolderView);
	//NSLog(@"TOUCHED BG:%d", [touch view] == _bgImgView);
	
	if ([touch view] != self.view) {
		[self _goPlayPause];
		return;
	}
}


#pragma mark - Notification handlers
-(void)_enteredFullscreen:(NSNotification *)notification {
	NSLog(@"_enteredFullscreen");
	_isFullscreen = YES;
}

-(void)_leftFullscreen:(NSNotification *)notification {
	NSLog(@"_leftFullscreen");
	
	_isFullscreen = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
}

-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----[STARTED PLAYBACK]----");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	
	_isFinished = NO;
	_isPaused = NO;
	_isStalled = NO;
	
	[_timer invalidate];
	_timer = nil;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_videoHolderView.alpha = 1.0;
		_playButton.alpha = 0.0;
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_STARTED" object:nil];
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerTick) userInfo:nil repeats:YES];
}

-(void)_finishedCallback:(NSNotification *)notification {
	NSLog(@"----[FINISHED PLAYBACK](%f, %f)----", self.mpc.currentPlaybackTime, self.mpc.duration);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	_isFinished = YES;
	
	[_timer invalidate];
	_timer = nil;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_playButton.alpha = 0.0;
		_videoHolderView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		[_articleFollowerView removeFromSuperview];
		[self.mpc.view removeFromSuperview];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
		[self dismissViewControllerAnimated:NO completion:nil];
	}];
}

-(void)_loadStateChangedCallback:(NSNotification *)notification {
	NSLog(@"----[LOAD STATE CHANGED[%d]](%f, %f)----", self.mpc.loadState, self.mpc.naturalSize.width, self.mpc.naturalSize.height);
	
	switch (self.mpc.loadState) {
		case MPMovieLoadStatePlayable:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_DURATION" object:[NSNumber numberWithFloat:self.mpc.duration]];
			
			self.mpc.view.hidden = NO;
			[UIView animateWithDuration:0.5 delay:0.125 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
				self.mpc.view.alpha = 1.0;
			} completion:nil];
			
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
		case MPMoviePlaybackStatePlaying:
			break;
			
			//case 2:
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
			break;
			
	}
}


-(void)_playingChangeCallback:(NSNotification *)notification {
	NSLog(@"----[PLAYING CHANGED[%d]]----", self.mpc.playbackState);
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
	NSLog(@"requestStarted");
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
	
	NSRange prefixRange = [videoInfo rangeOfString:@"url_encoded_fmt_stream_map=url="];
	NSRange suffixRange = [videoInfo rangeOfString:@"&tmi=1"];
	NSLog(@"(%d) -- [%@][%@]", [videoInfo length], NSStringFromRange(prefixRange), NSStringFromRange(suffixRange));
	
	if (suffixRange.location < prefixRange.location)
		suffixRange = [videoInfo rangeOfString:@"&no_get_video_log=1"];
	
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
			
			NSLog(@"VIDEOS:\n\n[======================================================]\n%@\n[======================================================]\n", url);
		}
	}
	
	NSString *videoURL = [videoURLs objectForKey:@"sd"];
	
	//if ([videoURLs objectForKey:@"hd"])
	//	videoURL = [videoURLs objectForKey:@"hd"];
	
	
	NSLog(@"%@", videoURLs);
	
	
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoURL]];
	self.mpc = mp;
	[mp release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_finishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	self.mpc.controlStyle = MPMovieControlStyleNone;
	self.mpc.view.frame = CGRectMake(0.0, 0.0, _videoHolderView.frame.size.width, 180.0);
	self.mpc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.mpc.shouldAutoplay = YES;
	self.mpc.allowsAirPlay = YES;
	self.mpc.movieSourceType = MPMovieSourceTypeFile;
	[self.mpc prepareToPlay];
	[self.mpc setFullscreen:YES];
	[self.mpc play];
	
	self.mpc.view.alpha = 0.0;
	self.mpc.view.hidden = YES;
	[_videoHolderView addSubview:self.mpc.view];
	
	_progressView.frame = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, 0.0, _progressView.frame.size.height);
	_timeSize = [[NSString stringWithFormat:@"%@", @"0:00"] sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:10.0] constrainedToSize:CGSizeMake(96.0, 10.0) lineBreakMode:UILineBreakModeClip];
	_timeLabel.frame = CGRectMake(0.0, _timeLabel.frame.origin.y, _timeSize.width, _timeSize.height);
	_timeLabel.text = @"0:00";
	
	//NSLog(@"%@", [@"http%3A%2F%2Fo-o.preferred.comcast-lax1.v21.lscache4.c.youtube.com%2Fvideoplayback%3Fupn%3DNjE0NjE0NjY0NzY4NDEzNDA5OA%253D%253D%26sparams%3Dcp%252Cid%252Cip%252Cipbits%252Citag%252Cratebypass%252Csource%252Cupn%252Cexpire%26fexp%3D902904%252C904820%252C901601%26itag%3D37%26ip%3D98.0.0.0%26signature%3DAC36EF98C4CFECF8E5BFEA29EE9A009A40D18106.4BE3C83EE174FEC7EEDC72303CD49FCBE4F9F150%26sver%3D3%26ratebypass%3Dyes%26source%3Dyoutube%26expire%3D1332511088%26key%3Dyt1%26ipbits%3D8%26cp%3DU0hSR1VMT19NUkNOMl9NRlNBOjNqczdGMmdmd2pJ%26id%3Dd5783ada74dc476c" stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
}

-(void)requestRedirected:(ASIHTTPRequest *)request {
	NSLog(@"requestRedirected");
}

// When a delegate implements this method, it is expected to process all incoming data itself
// This means that responseData / responseString / downloadDestinationPath etc are ignored
// You can have the request call a different method by setting didReceiveDataSelector
//- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data {
//	NSLog(@"didReceiveData:\n[%@]", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//}

@end
