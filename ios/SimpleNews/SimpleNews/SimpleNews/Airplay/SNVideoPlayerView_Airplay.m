//
//  SNVideoPlayerView_Airplay.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerView_Airplay.h"
#import "SNVideoItemVO.h"

@interface SNVideoPlayerView_Airplay()
-(void)_startPlayback:(NSNotification *)notification;
-(void)_togglePlayback:(NSNotification *)notification;
-(void)_ffScrub:(NSNotification *)notification;
-(void)_rrScrub:(NSNotification *)notification;
@end

@implementation SNVideoPlayerView_Airplay

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startPlayback:) name:@"START_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_togglePlayback:) name:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_ffScrub:) name:@"FF_VIDEO_TIME" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rrScrub:) name:@"RR_VIDEO_TIME" object:nil];
		
		
		// VIDEO TAG -- AUTOSTART
		//NSString *videoURL = @"http://dev.gullinbursti.cc/projs/simplenews/app/videos/ffvi_intro.mp4";
		//NSString *videoURL = @"http://o-o.preferred.comcast-lax1.v23.lscache6.c.youtube.com/videoplayback?sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Csource%2Cratebypass%2Ccp&fexp=902906%2C916103%2C913533&itag=37&ip=98.0.0.0&signature=451B473A71E81FB58C74BC1444F9A54F959A968A.9A991C6C5E7987FAD10E0961783C1B7DB7C72F67&sver=3&ratebypass=yes&source=youtube&expire=1330523534&key=yt1&ipbits=8&cp=U0hSRVVNUV9ITkNOMl9NR1VGOlliZzRnUF9vSEJB&id=de14a29a6770103e&title=UMP45%20INCENDIARY%20AMMO";
		//NSString *videoURL = @"http://o-o.preferred.comcast-lax1.v18.lscache6.c.youtube.com/videoplayback?sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Csource%2Cratebypass%2Ccp&fexp=902906%2C916103%2C913533&itag=22&ip=98.0.0.0&signature=3B99F8351D93AB67EE71BD591B79AD9925A46293.1D62C9F376B243CE933918F8383EE09712F405FF&sver=3&ratebypass=yes&source=youtube&expire=1330523927&key=yt1&ipbits=8&cp=U0hSRVVNUV9HUUNOMl9NR1VKOkJiZzRnUF9vTEFE&id=f1479efe6731bebc&title=I%20FINK%20U%20FREEKY%20by%20DIE%20ANTWOORD%20(Official)";
		

		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video_player" ofType:@"html"]]];
		
		
		_webView = [[UIWebView alloc] initWithFrame:frame];
		[_webView setBackgroundColor:[UIColor redColor]];
		_webView.delegate = self;
		_webView.allowsInlineMediaPlayback = YES;
		_webView.mediaPlaybackRequiresUserAction = NO;
		//[_webView loadHTMLString:htmlString baseURL:nil];
		[_webView loadRequest:request];
		[self addSubview:_webView];
	}
	
	return (self);
}

#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	NSLog(@"VIDEO CHANGE:[%@]", vo.video_title);
	
	NSString *videoURL = @"http://o-o.preferred.comcast-lax1.v18.lscache6.c.youtube.com/videoplayback?sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Csource%2Cratebypass%2Ccp&fexp=902906%2C916103%2C913533&itag=22&ip=98.0.0.0&signature=3B99F8351D93AB67EE71BD591B79AD9925A46293.1D62C9F376B243CE933918F8383EE09712F405FF&sver=3&ratebypass=yes&source=youtube&expire=1330523927&key=yt1&ipbits=8&cp=U0hSRVVNUV9HUUNOMl9NR1VKOkJiZzRnUF9vTEFE&id=f1479efe6731bebc&title=I%20FINK%20U%20FREEKY%20by%20DIE%20ANTWOORD%20(Official)";
	NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0, user-scalable = no, width = 320\"/></head><body style=\"background-color:black;\"><div style=\"text-align:center;\"><video id=\"video1\" autoplay webkit-playsinline onloadedmetadata=\"onMetadata()\" onended=\"onPlaybackEnded()\"><source src=\"%@\" type=\"video/mp4\" onerror=\"onError()\" />Your browser does not support HTML5 video.</video></div><script type=\"text/javascript\">var video_obj=document.getElementById('video1'); video_obj.addEventListener(\"timeupdate\", function(){sendValue('time', video_obj.currentTime);}, false); function onMetadata(){sendValue('duration', video_obj.duration);} function onPlaybackEnded(){sendValue('state', \"ENDED\");} function onError(){sendValue('state', \"ERROR\");} function rr(){if(video_obj.currentTime>0)video_obj.currentTime -= 0.5;} function ff(){if(video_obj.currentTime<video_obj.duration)video_obj.currentTime += 0.5;} function playPause() {if (video_obj.paused) video_obj.play(); else video_obj.pause();} function sendValue(key, val) {location.href = 'result://keyval/' + key + '/' + val;}</script></body></html>", videoURL];
	[_webView loadHTMLString:htmlString baseURL:nil];
}

-(void)_startPlayback:(NSNotification *)notification {
	NSLog(@"----START PLAYBACK-----");
	
	_isPaused = NO;
	_isFinished = NO;
	[_webView stringByEvaluatingJavaScriptFromString:@"playPause();"];
	
//	UIView *derpView = [[[UIView alloc] initWithFrame:CGRectMake(128.0, 128.0, 64.0, 64.0)] autorelease];
//	[derpView setBackgroundColor:[UIColor yellowColor]];
//	[self addSubview:derpView];
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




#pragma mark - WebView delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *urlString = [[request URL] absoluteString];
	
	if ([urlString hasPrefix:@"result:"]) {
		NSArray *pathComponents = [[[request URL] path] pathComponents];
		
		NSString *key = [pathComponents objectAtIndex:1];
		NSString *value = [pathComponents objectAtIndex:2];
		
		//NSLog(@"['%@'] = \"%@\"", key, value);
		
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
