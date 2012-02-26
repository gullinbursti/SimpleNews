//
//  SNVideoPlayerView_Airplay.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerView_Airplay.h"

@implementation SNVideoPlayerView_Airplay

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_finishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_stateChangedCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		
		//NSString *htmlString = @"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0, user-scalable = no, width = 1280\"/></head><body><div style=\"text-align:center\"><video id=\"video1\" width=\"1280\" height=\"720\" preload=\"auto\" webkit-playsinline><source src=\"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4\" type=\"video/mp4\" />Your browser does not support HTML5 video.</video></div><script type=\"text/javascript\">var myVideo=document.getElementById('video1'); function playPause(){if (myVideo.paused) myVideo.play(); else myVideo.pause();}</script></body></html>";
		NSString *htmlString = @"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0, user-scalable = no, width = 1280\"/></head><body><div style=\"text-align:center\"><video id=\"video1\" width=\"1280\" height=\"720\" preload=\"auto\" webkit-playsinline><source src=\"http://o-o.preferred.comcast-lax1.v17.lscache8.c.youtube.com/videoplayback?sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Csource%2Cratebypass%2Ccp&fexp=902906%2C916103%2C913533&itag=22&ip=98.0.0.0&signature=656A52AE44545FA92C6E67BBA45846871DBA5FB3.B4D94BF11B8E5515D3828166447A79FC5C6E683F&sver=3&ratebypass=yes&source=youtube&expire=1330236207&key=yt1&ipbits=8&cp=U0hSRVJOVF9FUUNOMl9KSFhDOkJiZzRnTV9yRVlE&id=c15baec91181fc10&title=Duke%20Nukem%20Forever%20Official%20HD%20Debut%20Trailer\" type=\"video/mp4\" />Your browser does not support HTML5 video.</video></div><script type=\"text/javascript\">var myVideo=document.getElementById('video1'); function playPause(){if (myVideo.paused) myVideo.play(); else myVideo.pause();}</script></body></html>";
		
		_webView = [[UIWebView alloc] initWithFrame:frame];
		[_webView setBackgroundColor:[UIColor redColor]];
		_webView.allowsInlineMediaPlayback = YES;
		[_webView loadHTMLString:htmlString baseURL:nil];
		[self addSubview:_webView];
		
		/*
		//_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://o-o.preferred.comcast-lax1.v17.lscache8.c.youtube.com/videoplayback?sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Csource%2Cratebypass%2Ccp&fexp=902906%2C916103%2C913533&itag=22&ip=98.0.0.0&signature=4001D0E6970AB574B9264BECB835C3CA9CF597A3.75D481B6D6A72C5252F367FFF42942C14B6CAAC4&sver=3&ratebypass=yes&source=youtube&expire=1329818607&key=yt1&ipbits=8&cp=U0hRTlhMVl9FUUNOMV9QRlpHOkJiZzNwU190SVlE&id=c15baec91181fc10&title=Duke%20Nukem%20Forever%20Official%20HD%20Debut%20Trailer"]];
		//_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/gutz/video/device-demo_[08.30.2011]-485kbs.mov"]];
		_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
		//_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"rtsp://v3.cache6.c.youtube.com/CiILENy73wIaGQkEKKuVj--CKRMYDSANFEgGUgZ2aWRlb3MM/0/0/0/video.3gp"]];
		_playerController.controlStyle = MPMovieControlStyleNone;
		_playerController.view.frame = frame;
		_playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_playerController.shouldAutoplay = NO;
		_playerController.allowsAirPlay = YES;
		_playerController.movieSourceType = MPMovieSourceTypeFile;
		[_playerController prepareToPlay];
		[_playerController setFullscreen:NO];
		
		
		//[_playerController play];
		[self addSubview:_playerController.view];
		
		UIImage *thumbImage = [_playerController thumbnailImageAtTime:10.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
		if (thumbImage == nil)
			NSLog(@"NO THUMB!!");
		
		else {
			UIImageView *thumbImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 360.0, 1280.0, 720.0)] autorelease];
			thumbImageView.image = thumbImage;
			//[self addSubview:thumbImageView];
		}
		*/
	}
	
	return (self);
}


-(void)togglePlayback:(BOOL)isPlaying {
	NSLog(@"----TOGGLE PLAYBACK----");
	[_webView stringByEvaluatingJavaScriptFromString:@"playPause();"];
	
	/*
	if (!_isFinished)
		[_playerController stop];
	
	[_playerController setContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
	//[_playerController setContentURL:[NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/gutz/video/device-demo_[08.30.2011]-485kbs.mov"]];
	[_playerController play];
	
	[_playerController autorelease];
	
	_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
	_playerController.controlStyle = MPMovieControlStyleNone;
	_playerController.view.frame = self.frame;
	_playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_playerController.shouldAutoplay = NO;
	_playerController.allowsAirPlay = YES;
	_playerController.movieSourceType = MPMovieSourceTypeFile;
	[_playerController prepareToPlay];
	[_playerController setFullscreen:NO];
	[self addSubview:_playerController.view];
	[_playerController play];*/
}


#pragma mark - Notification handlers
-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----STARTED PLAYBACK----(%f)", _playerController.duration);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	
	_isFinished = NO;
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_timerTick) userInfo:nil repeats:YES];
}

-(void)_finishedCallback:(NSNotification *)notification {
	NSLog(@"----FINISHED PLAYBACK----");
	
	_isFinished = YES;
	[_timer invalidate];
	_timer = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];    
	[_playerController autorelease];
}

-(void)_stateChangedCallback:(NSNotification *)notification {
	NSLog(@"----STATE CHANGED----");
	
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}



-(void)_timerTick {
	NSLog(@"%d, %d", (int)_playerController.duration, (int)_playerController.endPlaybackTime);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_PROGRESSION" object:[NSNumber numberWithFloat:_playerController.currentPlaybackTime]];
}

@end
