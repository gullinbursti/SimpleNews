//
//  SNVideoPlayerView_Airplay.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerView_Airplay.h"
#import "SNAppDelegate.h"
#import "UIImage+StackBlur.h"

#import "SNLogoView.h"

@implementation SNVideoPlayerView_Airplay

@synthesize mpc;

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startPlayback:) name:@"START_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_togglePlayback:) name:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startScrubbing:) name:@"START_VIDEO_SCRUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_stopScrubbing:) name:@"STOP_VIDEO_SCRUB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_ffScrub:) name:@"FF_VIDEO_TIME" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rrScrub:) name:@"RR_VIDEO_TIME" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeVideo:) name:@"CHANGE_VIDEO" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playbackStateChangedCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateChangedCallback:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		
		_videoHolderView = [[UIView alloc] initWithFrame:frame];
		[self addSubview:_videoHolderView];
		
		_overlayHolderView = [[UIView alloc] initWithFrame:frame];
		_overlayHolderView.hidden = YES;
		[self addSubview:_overlayHolderView];
		
		
		_overlayImgView = [[EGOImageView alloc] initWithFrame:frame];
		_overlayImgView.alpha = 0.33;
		_overlayImgView.clipsToBounds = YES;
		_overlayImgView.transform = CGAffineTransformMakeScale(1.33, 1.33);
		_overlayImgView.image = [_overlayImgView.image stackBlur:4];
		[_overlayHolderView addSubview:_overlayImgView];
		
		/*
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

-(void)setupMPC {
	NSLog(@"----[PLAYER SETUP]----(%@)", _videoURL);
	
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_videoURL]];;
	self.mpc = mp;
	[mp release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vcFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	self.mpc.controlStyle = MPMovieControlStyleNone;
	self.mpc.view.frame = self.frame;
	self.mpc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.mpc.shouldAutoplay = YES;
	self.mpc.allowsAirPlay = YES;
	self.mpc.movieSourceType = MPMovieSourceTypeFile;
	[self.mpc prepareToPlay];
	[self.mpc setFullscreen:NO];
	self.mpc.view.hidden = YES;
	
	[_videoHolderView addSubview:self.mpc.view];
	
	_overlayImgView.imageURL = [NSURL URLWithString:_vo.thumb_url];
	_overlayImgView.image = [_overlayImgView.image stackBlur:8];

	_hud = [MBProgressHUD showHUDAddedTo:_overlayHolderView animated:YES];
	_hud.labelFont = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	_hud.labelText = @"Loading…";
	_hud.dimBackground = NO;
	
	_overlayHolderView.hidden = NO;
}


-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----[STARTED PLAYBACK]----");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	
	_duration = -1.0;
	_isFinished = NO;
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_timerTick) userInfo:nil repeats:YES];
}

-(void)vcFinished:(NSNotification *)notification {
	NSLog(@"----[FINISHED PLAYBACK]----");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	_isFinished = YES;
	
	[_timer invalidate];
	_timer = nil;
	
	[self.mpc.view removeFromSuperview];
	[self setupMPC];
}

-(void)_loadStateChangedCallback:(NSNotification *)notification {
	NSLog(@"----[LOAD STATE CHANGED[%d]]----", self.mpc.loadState);
}

-(void)_playbackStateChangedCallback:(NSNotification *)notification {
	NSLog(@"----[PLAYBACK STATE CHANGED[%d]]----", self.mpc.playbackState);
}


#pragma mark - Notification handlers
-(void)_startPlayback:(NSNotification *)notification {
	NSLog(@"START PLAYBACK");
	
	_videoURL = [notification object];
	[self setupMPC];
}

-(void)_togglePlayback:(NSNotification *)notification {
	NSLog(@"TOGGLE PLAYBACK(%d)", self.mpc.playbackState);
	
	
	switch (self.mpc.playbackState) {
		case MPMoviePlaybackStatePlaying:
			[self.mpc pause];
			break;
			
		case MPMoviePlaybackStatePaused:
			[self.mpc play];
			break;
			
		default:
			[self.mpc play];
			break;
	}
}

-(void)_itemTapped:(NSNotification *)notification {
	_vo = (SNVideoItemVO *)[notification object];
	NSLog(@"---ITEM TAPPED:[%@]---", _vo.video_title);
	
	[self.mpc stop];
	
	_isPaused = YES;
	_isFinished = NO;
}

-(void)_changeVideo:(NSNotification *)notification {
	_vo = (SNVideoItemVO *)[notification object];
	NSLog(@"---CHANGE VIDEO:[%@]---", _vo.video_url);
	_videoURL = _vo.video_url;
		
	[self setupMPC];
}


-(void)_ffScrub:(NSNotification *)notification {
	NSLog(@"----FF SCRUB----");
	
	self.mpc.currentPlaybackTime++;
}

-(void)_rrScrub:(NSNotification *)notification {
	NSLog(@"----RR SCRUB----");
	
	self.mpc.currentPlaybackTime--;
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







-(void)_timerTick {
	NSLog(@"VIDEO POS:[%f/%f]", self.mpc.currentPlaybackTime, self.mpc.duration);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_TIME" object:[NSNumber numberWithFloat:self.mpc.currentPlaybackTime]];
	if (!_overlayHolderView.hidden && self.mpc.currentPlaybackTime > 0.0) {
		_overlayHolderView.hidden = YES;
		self.mpc.view.hidden = NO;
		
		if (_hud != nil) {
			[_hud removeFromSuperview];
			_hud = nil;
		}
	}
	
	if (_duration == -1.0 && self.mpc.duration > 0.0) {
		_duration = self.mpc.duration;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_DURATION" object:[NSNumber numberWithFloat:self.mpc.duration]];
	}
}



@end



















/*
//
//  SNVideoPlayerView_Airplay.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNVideoPlayerView_Airplay.h"
#import "SNVideoItemVO.h"

#import "UIImage+StackBlur.h"
#import "SNAppDelegate.h"

@interface SNVideoPlayerView_Airplay()
-(void)_startPlayback:(NSNotification *)notification;
-(void)_togglePlayback:(NSNotification *)notification;
-(void)_ffScrub:(NSNotification *)notification;
-(void)_rrScrub:(NSNotification *)notification;

-(void)_delayedPlayback;
-(void)_delayedLoad;
@end

@implementation SNVideoPlayerView_Airplay

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeVideo:) name:@"CHANGE_VIDEO" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startPlayback:) name:@"START_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_togglePlayback:) name:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_ffScrub:) name:@"FF_VIDEO_TIME" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rrScrub:) name:@"RR_VIDEO_TIME" object:nil];
		
		
		// VIDEO TAG -- AUTOSTART
		//NSString *videoURL = @"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4";
		//NSString *videoURL = @"http://o-o.preferred.comcast-lax1.v22.lscache7.c.youtube.com/videoplayback?sparams=cp%2Cid%2Cip%2Cipbits%2Citag%2Cratebypass%2Csource%2Cexpire&fexp=902906%2C916103%2C913533&itag=22&ip=98.0.0.0&signature=D3CAA3944A2927FEA82E01720369E20FFA0F18F1.28BB09E543D8E373F59A302E024918B7E8D6A457&sver=3&ratebypass=yes&source=youtube&expire=1330591934&key=yt1&ipbits=8&cp=U0hSRVVUT19ITkNOMl9NTlNKOlliZzRnUF9tTEJB&id=de14a29a6770103e&title=UMP45%20INCENDIARY%20AMMO";
		//NSString *videoURL = @"http://o-o.preferred.comcast-lax1.v18.lscache6.c.youtube.com/videoplayback?sparams=cp%2Cid%2Cip%2Cipbits%2Citag%2Cratebypass%2Csource%2Cexpire&fexp=902906%2C916103%2C913533&itag=22&ip=98.0.0.0&signature=24FE6A4DC255828826F1B9E6AF0F022118988343.32754FD15D62608C0CED890E0727C0637E70C512&sver=3&ratebypass=yes&source=youtube&expire=1330588727&key=yt1&ipbits=8&cp=U0hSRVVTVl9HUUNOMl9NTVpIOkJiZzRnUF90SkFE&id=f1479efe6731bebc&title=I%20FINK%20U%20FREEKY%20by%20DIE%20ANTWOORD%20(Official)";
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video_player" ofType:@"html"]]];
		
		_webView = [[UIWebView alloc] initWithFrame:frame];
		_webView.delegate = self;
		_webView.allowsInlineMediaPlayback = YES;
		_webView.mediaPlaybackRequiresUserAction = NO;
		[_webView loadRequest:request];
		[self addSubview:_webView];
		
		_overlayImgView = [[EGOImageView alloc] initWithFrame:frame];
		
		_overlayImgView.alpha = 0.33;
		//_overlayImgView.imageURL = [NSURL URLWithString:@"http://i.ytimg.com/vi/8Uee_mcxvrw/hqdefault.jpg"];
		_overlayImgView.clipsToBounds = YES;
		_overlayImgView.hidden = YES;
		_overlayImgView.transform = CGAffineTransformMakeScale(1.33, 1.33);
		_overlayImgView.image = [_overlayImgView.image stackBlur:4];
		[self addSubview:_overlayImgView];
	}
	
	return (self);
}

#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	_vo = (SNVideoItemVO *)[notification object];
	NSLog(@"---ITEM TAPPED:[%@]---", _vo.video_title);
	
	[_webView stringByEvaluatingJavaScriptFromString:@"playPause();"];
}

-(void)_changeVideo:(NSNotification *)notification {
	_vo = (SNVideoItemVO *)[notification object];
	NSLog(@"---CHANGE VIDEO:[%@]---", _vo.video_title);
	
	_isPaused = YES;
	_isFinished = NO;
	
	_hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
	_hud.labelFont = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	_hud.labelText = @"Loading…";
	_hud.dimBackground = NO;
	
	_overlayImgView.imageURL = [NSURL URLWithString:_vo.thumb_url];
	_overlayImgView.image = [_overlayImgView.image stackBlur:8];
	_overlayImgView.hidden = NO;
	

//	UIGraphicsBeginImageContext(_webView.bounds.size);
//	[_webView.layer renderInContext:UIGraphicsGetCurrentContext()];
//	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();

	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video_player" ofType:@"html"]]];
	[_webView loadRequest:request];
	
	//[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_delayedLoad) userInfo:nil repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:3.333 target:self selector:@selector(_delayedPlayback) userInfo:nil repeats:NO];
}

-(void)_startPlayback:(NSNotification *)notification {
	NSLog(@"----START PLAYBACK-----");
	
	_isPaused = NO;
	_isFinished = NO;
	[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeVideo('%@');", [notification object]]];
}

-(void)_togglePlayback:(NSNotification *)notification {
	NSLog(@"----TOGGLE PLAYBACK----");
	
	BOOL isPlaying = [[notification object] isEqualToString:@"YES"];
	
	_isPaused = !isPlaying;
	[_webView stringByEvaluatingJavaScriptFromString:@"playPause();"];
}


-(void)_ffScrub:(NSNotification *)notification {
	NSLog(@"----FF SCRUB----");
	
	[_webView stringByEvaluatingJavaScriptFromString:@"ff();"];
}

-(void)_rrScrub:(NSNotification *)notification {
	NSLog(@"----RR SCRUB----");
	
	[_webView stringByEvaluatingJavaScriptFromString:@"rr();"];
}


-(void)_delayedLoad {
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video_player" ofType:@"html"]]];
	[_webView loadRequest:request];
}

-(void)_delayedPlayback {
	NSLog(@"VIDEO CHANGE:[%@]", _vo.video_url);
	
	_isPaused = NO;
	_overlayImgView.hidden = YES;
	
	if (_hud != nil) {
		[_hud removeFromSuperview];
		_hud = nil;
	}
	
	[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeVideo('%@');", _vo.video_url]];
}


#pragma mark - WebView delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *urlString = [[request URL] absoluteString];
	
	if ([urlString hasPrefix:@"result:"]) {
		NSArray *pathComponents = [[[request URL] path] pathComponents];
		
		NSString *key = [pathComponents objectAtIndex:1];
		NSString *value = [pathComponents objectAtIndex:2];
		
		NSLog(@"['%@'] = \"%@\"", key, value);
		
		if ([key isEqualToString:@"duration"]) {
			_duration = [value floatValue];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_DURATION" object:[NSNumber numberWithFloat:_duration]];
			
		} else if ([key isEqualToString:@"time"]) {
			float currTime = [value floatValue];
			
			if (_duration > 0.0) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_TIME" object:[NSNumber numberWithFloat:currTime]];
			}
			
		} else if ([key isEqualToString:@"state"]) {
			if ([value isEqualToString:@"ENDED"]) {
				_isFinished = YES;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
				
			} else {
				NSLog(@"ERROR");
			}
		}
		
		
		return (NO);
		
	} else
		return (YES);
}


-(void)webViewDidStartLoad:(UIWebView *)webView {
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {	
}


@end
*/
