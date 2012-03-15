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
		
		[self setBackgroundColor:[UIColor blackColor]];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"youtube_player" ofType:@"html"]]];
		
		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
		[_webView setBackgroundColor:[UIColor blackColor]];
		_webView.delegate = self;
		_webView.allowsInlineMediaPlayback = YES;
		_webView.mediaPlaybackRequiresUserAction = NO;
		[_webView loadRequest:request];
		[self addSubview:_webView];
	}
	
	return (self);
}

-(void)dealloc {
	[_webView release];
	
	[super dealloc];
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
}

-(void)_leftFullscreen:(NSNotification *)notification {
	NSLog(@"_leftFullscreen");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
	//[self.na
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
				//	[self.navigationController popViewControllerAnimated:YES];
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
