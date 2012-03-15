//
//  SNArticleVideoPlayerViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleVideoPlayerViewController_iPhone.h"

@implementation SNArticleVideoPlayerViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startPlayback:) name:@"START_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_togglePlayback:) name:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_enteredFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leftFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
		
		_isFullscreen = NO;
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[_webView release];
	
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"youtube_player" ofType:@"html"]]];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	[_webView setBackgroundColor:[UIColor blackColor]];
	_webView.delegate = self;
	_webView.allowsInlineMediaPlayback = YES;
	_webView.mediaPlaybackRequiresUserAction = NO;
	[_webView loadRequest:request];
	[self.view addSubview:_webView];
	
	_overlayView = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
	[_overlayView setBackgroundColor:[UIColor blackColor]];
	[self.view addSubview:_overlayView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
	[self.navigationController dismissModalViewControllerAnimated:YES];
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
				[self.navigationController dismissModalViewControllerAnimated:YES];
				
				//if (!_isFullscreen)
				//	[_webView stringByEvaluatingJavaScriptFromString:@"playVideo();"];
			} else if ([value isEqualToString:@"PLAYING"]) {
				[_overlayView removeFromSuperview];
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
