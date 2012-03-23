//
//  SNVideoPlayerView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerView_iPhone.h"

@implementation SNVideoPlayerView_iPhone

@synthesize mpc;

/*
size_t write_data(void *buffer, size_t size, size_t nmemb, void *userp)
{
	NSLog(@"write_data len=%ld data='%s'", size, buffer);
	return size;
}
*/

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startPlayback:) name:@"START_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_togglePlayback:) name:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startScrubbing:) name:@"START_VIDEO_SCRUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_stopScrubbing:) name:@"STOP_VIDEO_SCRUB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_ffScrub:) name:@"FF_VIDEO_TIME" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rrScrub:) name:@"RR_VIDEO_TIME" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playbackStateChangedCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateChangedCallback:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playingChangeCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_enteredFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leftFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
		
//		CURL *curl = curl_easy_init();
//		CURLcode res;
//		
//		if (curl) {
//			curl_easy_setopt(curl, CURLOPT_URL, "http://www.youtube.com/get_video_info?html5=1&video_id=1Xg62nTcR2w&eurl=http%3A%2F%2Fshelby.tv%2F&ps=native&el=embedded&hl=en_US");
//			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
//			curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L); // skip verify since we don't have a certificate
//			res = curl_easy_perform(curl);
//			curl_easy_cleanup(curl);
//		}
		
		_videoHolderView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:_videoHolderView];
	}
	
	return (self);
}

-(void)dealloc {
	[_webView release];
	
	[super dealloc];
}






-(void)changeArticleVO:(SNArticleVO *)vo {
	_vo = vo;
	
	_isFullscreen = NO;
	_isFirstPlay = YES;
	
	NSLog(@"TITLE:[%@]", _vo.video_url);
	
	[self setBackgroundColor:[UIColor blackColor]];

	_videoInfoRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/get_video_info?html5=1&video_id=%@&eurl=http%3A%2F%2Fshelby.tv%2F&ps=native&el=embedded&hl=en_US", _vo.video_url]]];
	_videoInfoRequest.delegate = self;
	[_videoInfoRequest startAsynchronous];
	
	/*
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"youtube_player" ofType:@"html"]]];
	
	//http://www.youtube.com/get_video_info?html5=1&video_id=1Xg62nTcR2w&eurl=http%3A%2F%2Fshelby.tv%2F&ps=native&el=embedded&hl=en_US
	NSString *videoInfo = @"http://www.youtube.com/get_video_info?video_id=1Xg62nTcR2w";
	NSURLRequest *videoInfoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:videoInfo]];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 240.0)];
	[_webView setBackgroundColor:[UIColor blackColor]];
	//_webView.hidden = YES;
	_webView.delegate = self;
	_webView.allowsInlineMediaPlayback = YES;
	_webView.mediaPlaybackRequiresUserAction = NO;
	[_webView loadRequest:videoInfoRequest];
	[self addSubview:_webView];
	
	//[self performSelector:@selector(delay) withObject:nil afterDelay:1.33];
	
	_overlayView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
	[_overlayView setBackgroundColor:[UIColor blackColor]];
	[self addSubview:_overlayView];
	
	UIView *progressView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	progressView.frame = CGRectMake(144.0, 224.0, 32.0, 32.0);
	[(UIActivityIndicatorView *)progressView startAnimating];
	[self addSubview:progressView];
	 */
}


#pragma mark - Notification handlers
-(void)_enteredFullscreen:(NSNotification *)notification {
	NSLog(@"_enteredFullscreen");
	_isFullscreen = YES;
}

-(void)_leftFullscreen:(NSNotification *)notification {
	NSLog(@"_leftFullscreen");
	_isFullscreen = NO;
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
	//[self.navigationController dismissModalViewControllerAnimated:NO];
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		_overlayView.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
		//[self removeFromSuperview];
	}];
}

-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----[STARTED PLAYBACK]----");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	
	_duration = -1.0;
	_isFinished = NO;
	
	_isFirst = NO;
	_isStalled = NO;
	
	[_timer invalidate];
	_timer = nil;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_STARTED" object:nil];
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerTick) userInfo:nil repeats:YES];
}

-(void)vcFinished:(NSNotification *)notification {
	NSLog(@"----[FINISHED PLAYBACK](%f, %f)----", self.mpc.currentPlaybackTime, self.mpc.duration);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	_isFinished = YES;
	
	[_timer invalidate];
	_timer = nil;
	
	[self.mpc.view removeFromSuperview];
	
	if ((self.mpc.currentPlaybackTime > self.mpc.duration - 1.5) && (self.mpc.duration > 0.0))
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
}

-(void)_loadStateChangedCallback:(NSNotification *)notification {
	NSLog(@"----[LOAD STATE CHANGED[%d]](%f, %f)----", self.mpc.loadState, self.mpc.naturalSize.width, self.mpc.naturalSize.height);
	
	switch (self.mpc.loadState) {
		case MPMovieLoadStatePlayable:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_DURATION" object:[NSNumber numberWithFloat:self.mpc.duration]];
			
			//self.mpc.view.hidden = NO;
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
			
		case 2:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
			break;
		
	}
}


-(void)_playingChangeCallback:(NSNotification *)notification {
	NSLog(@"----[PLAYING CHANGED[%d]]----", self.mpc.playbackState);
}

-(void)_startPlayback:(NSNotification *)notification {
	NSLog(@"----START PLAYBACK-----");
	
	_isPaused = NO;
	_isFinished = NO;
	[_webView stringByEvaluatingJavaScriptFromString:@"playVideo();"];
} 

-(void)_togglePlayback:(NSNotification *)notification {
	NSLog(@"----TOGGLE PLAYBACK----");
	
	BOOL isPlaying = [[notification object] isEqualToString:@"YES"];
	
	_isPaused = !isPlaying;
	[_webView stringByEvaluatingJavaScriptFromString:@"playPause();"];
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
	//NSLog(@"%@", _videoInfo);
	//NSLog(@"(%d) -- [%@][%@]", [_videoInfo length], NSStringFromRange(prefixRange), NSStringFromRange(suffixRange));
	
	NSString *videoInfo = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSRange prefixRange = [videoInfo rangeOfString:@"url_encoded_fmt_stream_map=url="];
	NSRange suffixRange = [videoInfo rangeOfString:@"&tmi=1"];
	
	//NSString *streamMap = [_videoInfo substringWithRange:NSMakeRange(prefixRange.location + prefixRange.length, suffixRange.location - (prefixRange.location + prefixRange.length))];
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
	
	if ([videoURLs objectForKey:@"hd"])
		videoURL = [videoURLs objectForKey:@"hd"];
	
	
	NSLog(@"%@", videoURLs);
	
	
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoURL]];
	self.mpc = mp;
	[mp release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vcFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	//self.mpc.controlStyle = MPMovieControlStyleNone;
	self.mpc.controlStyle = MPMovieControlStyleEmbedded;
	self.mpc.view.frame = self.frame;
	self.mpc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.mpc.shouldAutoplay = YES;
	self.mpc.allowsAirPlay = YES;
	self.mpc.movieSourceType = MPMovieSourceTypeFile;
	[self.mpc prepareToPlay];
	[self.mpc setFullscreen:YES];
	[self.mpc play];
	
	self.mpc.view.alpha = 0.0;
	//self.mpc.view.hidden = YES;
	[_videoHolderView addSubview:self.mpc.view];
	
	
	
	//NSLog(@"%@", [@"http%3A%2F%2Fo-o.preferred.comcast-lax1.v21.lscache4.c.youtube.com%2Fvideoplayback%3Fupn%3DNjE0NjE0NjY0NzY4NDEzNDA5OA%253D%253D%26sparams%3Dcp%252Cid%252Cip%252Cipbits%252Citag%252Cratebypass%252Csource%252Cupn%252Cexpire%26fexp%3D902904%252C904820%252C901601%26itag%3D37%26ip%3D98.0.0.0%26signature%3DAC36EF98C4CFECF8E5BFEA29EE9A009A40D18106.4BE3C83EE174FEC7EEDC72303CD49FCBE4F9F150%26sver%3D3%26ratebypass%3Dyes%26source%3Dyoutube%26expire%3D1332511088%26key%3Dyt1%26ipbits%3D8%26cp%3DU0hSR1VMT19NUkNOMl9NRlNBOjNqczdGMmdmd2pJ%26id%3Dd5783ada74dc476c" stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed");
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



#pragma mark - WebView delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//NSString *urlString = [[request URL] absoluteString];
	/*
	if ([urlString hasPrefix:@"result:"]) {
		NSArray *pathComponents = [[[request URL] path] pathComponents];
		
		NSString *key = [pathComponents objectAtIndex:1];
		NSString *value = [pathComponents objectAtIndex:2];
		
		NSLog(@"['%@'] = \"%@\"", key, value);
		
		if ([key isEqualToString:@"state"]) {
			if ([value isEqualToString:@"ENDED"]) {
				
				_isFinished = YES;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
				//[self removeFromSuperview];
				
				//if (!_isFullscreen)
				//	[_webView stringByEvaluatingJavaScriptFromString:@"playVideo();"];
			} else if ([value isEqualToString:@"PLAYING"]) {
				//_overlayView.alpha = 0.0;
				//[_overlayView removeFromSuperview];
				
				if (_isFirstPlay) {
					_isFirstPlay = NO;
					[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_STARTED" object:nil];	
					//[_webView stringByEvaluatingJavaScriptFromString:@"pauseVideo();"];
					//_webView.hidden = NO;
				}
				
				if (!_isFullscreen) {
					//[_webView stringByEvaluatingJavaScriptFromString:@"stopVideo();"];
					//[_webView stringByEvaluatingJavaScriptFromString:@"playVideo();"];
					//[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadVideo(\"%@\");", _vo.video_url]];
					
					[_webView reload];
				}
				
			} else if ([value isEqualToString:@"BUFFERING"]) {
				if (_isFirstPlay) {
					_isFirstPlay = NO;
					[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_STARTED" object:nil];	
					//[_webView stringByEvaluatingJavaScriptFromString:@"pauseVideo();"];
					//_webView.hidden = NO;
				}
			}
		}		
		
		return (NO);
		
	} else */
		return (YES);
}


-(void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webViewDidStartLoad");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"VIDEO INFO:\n%@", [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"]);
	[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadVideo(\"%@\");", _vo.video_url]];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {	
	NSLog(@"didFailLoadWithError [%@]", error);
}

@end
