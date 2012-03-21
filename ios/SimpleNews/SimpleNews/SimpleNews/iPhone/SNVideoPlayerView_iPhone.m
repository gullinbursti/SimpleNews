//
//  SNVideoPlayerView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerView_iPhone.h"

@implementation SNVideoPlayerView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startPlayback:) name:@"START_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_togglePlayback:) name:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_enteredFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leftFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
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
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"youtube_player" ofType:@"html"]]];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 240.0)];
	[_webView setBackgroundColor:[UIColor blackColor]];
	_webView.hidden = YES;
	_webView.delegate = self;
	_webView.allowsInlineMediaPlayback = YES;
	_webView.mediaPlaybackRequiresUserAction = NO;
	[_webView loadRequest:request];
	[self addSubview:_webView];
	
	//[self performSelector:@selector(delay) withObject:nil afterDelay:1.33];
	
	_overlayView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
	[_overlayView setBackgroundColor:[UIColor blackColor]];
	[self addSubview:_overlayView];
	
	UIView *progressView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	progressView.frame = CGRectMake(144.0, 224.0, 32.0, 32.0);
	[(UIActivityIndicatorView *)progressView startAnimating];
	[self addSubview:progressView];
}


#pragma mark - Notification handlers
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


#pragma mark - WebView delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *urlString = [[request URL] absoluteString];
	
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
		
	} else
		return (YES);
}


-(void)webViewDidStartLoad:(UIWebView *)webView {
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadVideo(\"%@\");", _vo.video_url]];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {	
}

@end
