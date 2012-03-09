//
//  SNPlayingListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNPlayingListViewController_iPhone.h"

#import "SNVideoItemVO.h"
#import "SNPlayingVideoItemView_iPhone.h"
#import "SNAppDelegate.h"

@interface SNPlayingListViewController_iPhone()
-(void)_resetMe;
-(void)cleanup_;
-(BOOL)doRetry_;
@end

@implementation SNPlayingListViewController_iPhone

#define kMaxNumberOfRetries 2 // numbers of retries
#define kWatchdogDelay 5.f    // seconds we wait for the DOM
#define kExtraDOMDelay 3.f    // if DOM doesn't load, wait for some extra time

-(id)initWithVO:(SNChannelVO *)vo {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoDuration:) name:@"VIDEO_DURATION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemDetailsScroll:) name:@"ITEM_DETAILS_SCROLL" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoStalled:) name:@"VIDEO_STALLED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoResumed:) name:@"VIDEO_RESUMED" object:nil];
		
//		_videoItems = videos;
		_views = [[NSMutableArray alloc] init];
		_lastOffset = 0.0;
		_index = 0;
		
		_htmlString = @"<html><head><style type=\"text/css\"> \
		body {background-color:green;color:black;}</style> \
		</head><body style=\"margin:0\"> \
		<embed id=\"yt\" src=\"http://www.youtube.com/watch?v=%@\" type=\"application/x-shockwave-flash\" \
		width=\"320\" height=\"180\"></embed></body></html>";  
		
		_videosRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Channels.php"]]] retain];
		[_videosRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_videosRequest setPostValue:vo.youtube_id forKey:@"id"];
		[_videosRequest setPostValue:vo.channel_title forKey:@"name"];
		[_videosRequest setTimeOutSeconds:30];
		[_videosRequest setDelegate:self];
		[_videosRequest startAsynchronous];
	}
	
	return (self);
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor colorWithWhite:0.196 alpha:1.0]];
	
	_videoPlayerViewController = [[SNVideoPlayerViewController_iPhone alloc] init];
	_videoPlayerViewController.view.frame = CGRectMake(0.0, -0.0, self.view.frame.size.width, 180.0);
	[self.view addSubview:_videoPlayerViewController.view];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.delegate = self;
	_scrollView.opaque = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width * [_videoItems count], self.view.frame.size.height);
	_scrollView.pagingEnabled = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	[self.view addSubview:_scrollView];
	
	/*
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 180.0)];
	_webView.delegate = self;
	_webView.allowsInlineMediaPlayback = YES;
	_webView.mediaPlaybackRequiresUserAction = NO;
	[self.view addSubview:_webView];
	*/
	_overlayHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 180.0)];
	[self.view addSubview:_overlayHolderView];
	
	_gridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_gridButton.frame = CGRectMake(0.0, 0.0, 34.0, 34.0);
	[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridButton_nonActive.png"] forState:UIControlStateNormal];
	[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridButton_Active.png"] forState:UIControlStateHighlighted];
	[_gridButton addTarget:self action:@selector(_goGrid) forControlEvents:UIControlEventTouchUpInside];
	[_overlayHolderView addSubview:_gridButton];
	
	_playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_playButton.frame = CGRectMake(17.0, 110.0, 64.0, 64.0);
	_playButton.hidden = YES;
	[_playButton setBackgroundImage:[UIImage imageNamed:@"playButton_nonActive.png"] forState:UIControlStateNormal];
	[_playButton setBackgroundImage:[UIImage imageNamed:@"playButton_Active.png"] forState:UIControlStateHighlighted];
	[_playButton addTarget:self action:@selector(_goPlay) forControlEvents:UIControlEventTouchUpInside];
	[_overlayHolderView addSubview:_playButton];
	
	_pauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_pauseButton.frame = CGRectMake(17.0, 110.0, 64.0, 64.0);
	[_pauseButton setBackgroundImage:[UIImage imageNamed:@"pauseButton_nonActive.png"] forState:UIControlStateNormal];
	[_pauseButton setBackgroundImage:[UIImage imageNamed:@"pauseButton_Active.png"] forState:UIControlStateHighlighted];
	[_pauseButton addTarget:self action:@selector(_goPause) forControlEvents:UIControlEventTouchUpInside];
	[_overlayHolderView addSubview:_pauseButton];
	
	MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(270.0, 17.0, 40.0, 20.0)];
	[volumeView setShowsVolumeSlider:NO];
	[volumeView sizeToFit];
	[_overlayHolderView addSubview:volumeView];
	
	UIImageView *hdImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(284.0, 200.0, 34.0, 34.0)] autorelease];
	hdImgView.image = [UIImage imageNamed:@"hd-logo.png"];
	[self.view addSubview:hdImgView];
	
}

-(void)viewDidLoad {
	[super viewDidLoad];
}


-(void)viewDidUnload {
	[super viewDidUnload];
}



-(void)_resetMe {
	_pauseButton.hidden = YES;
	_playButton.hidden = NO;
	
	_index = 0;
	
	_scrollView.contentOffset = CGPointMake(_index * 320.0, 0.0);
	_gridButton.frame = CGRectMake(0.0, 0.0, _gridButton.frame.size.width, _gridButton.frame.size.height);
	_videoPlayerViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 180.0);
	[_paginationView updToPage:(int)(_scrollView.contentOffset.x / self.view.frame.size.width)];
	
	[UIView animateWithDuration:0.25 delay:0.33 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		_overlayHolderView.frame = CGRectMake(0.0, 0.0, _overlayHolderView.frame.size.width, _overlayHolderView.frame.size.height);
		
	} completion:nil];
}

-(void)changeChannelVO:(SNChannelVO *)vo {
	
	for (SNPlayingVideoItemView_iPhone *videoItemView in _views) {
		[videoItemView removeFromSuperview];
		videoItemView = nil;
	}
	
	[_paginationView removeFromSuperview];
	
	_videosRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Channels.php"]]] retain];
	[_videosRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[_videosRequest setPostValue:vo.youtube_id forKey:@"id"];
	[_videosRequest setPostValue:vo.channel_title forKey:@"name"];
	[_videosRequest setTimeOutSeconds:30];
	[_videosRequest setDelegate:self];
	[_videosRequest startAsynchronous];
}

-(void)offsetAtIndex:(int)ind {
	_index = ind;
	
	_pauseButton.hidden = YES;
	_playButton.hidden = NO;
	
	_scrollView.contentOffset = CGPointMake(_index * 320.0, 0.0);
	_gridButton.frame = CGRectMake(-_gridButton.frame.size.width, -_gridButton.frame.size.height, _gridButton.frame.size.width, _gridButton.frame.size.height);
	_videoPlayerViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 180.0);
	[_paginationView updToPage:(int)(_scrollView.contentOffset.x / self.view.frame.size.width)];
	
	[UIView animateWithDuration:0.25 delay:0.33 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		_overlayHolderView.frame = CGRectMake(0.0, 0.0, _overlayHolderView.frame.size.width, _overlayHolderView.frame.size.height);
	
	} completion:nil];
}


#pragma mark - Navigation
-(void)_goGrid {
	[self cleanup_];
	[_videoPlayerViewController.mpc stop];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DETAILS_RETURN" object:nil];	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goPlay {
	_playButton.hidden = YES;
	_pauseButton.hidden = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
}

-(void)_goPause {
	_pauseButton.hidden = YES;
	_playButton.hidden = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
}


- (void)DOMLoaded_ {
	// ugly hack to see what's going on.
	//[[[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController] view] addSubview:webView_];
	//webView_.frame = [UIScreen mainScreen].bounds;
	
	// figure out if we can extract the youtube url!
	NSString *youTubeMP4URL = [webView_ stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video')[0].getAttribute('src')"];
	NSLog(@"testing dom. query: %@", youTubeMP4URL);
	
	if ([youTubeMP4URL hasPrefix:@"http"]) {
		// probably ok
		//NSURL *URL = [NSURL URLWithString:youTubeMP4URL];
		NSLog(@"Finished extracting: %@", youTubeMP4URL);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:youTubeMP4URL];
		
		
		[self cleanup_];
		
	} else {
		if (domWaitCounter_ < kExtraDOMDelay * 4) {
			domWaitCounter_++;
			[self performSelector:@selector(DOMLoaded_) withObject:nil afterDelay:0.25f]; // try often!
			return;
		}
		
		if (![self doRetry_]) {
			//NSError *error = [NSError errorWithDomain:@"com.petersteinberger.betteryoutube" code:100 userInfo:[NSDictionary dictionaryWithObject:@"MP4 URL could not be found." forKey:NSLocalizedDescriptionKey]];
			//if (failureBlock_) {
			//	failureBlock_(error);
			//}
			[self cleanup_];
		}
	}
}

- (void)DOMFailed_:(NSError *)error {
	if (![self doRetry_]) {
		NSLog(@"FAILED!!!");
		
		[self cleanup_];
	}
}

// very possible that the DOM isn't really loaded after all or sth failed. Try to load website again.
- (BOOL)doRetry_ {
	NSLog(@"doRetry_");
	
	// stop if we don't have a selfReference. (cleanup was called)
	if ((retryCount_ <= kMaxNumberOfRetries + 1)) {
		retryCount_++;
		domWaitCounter_ = 0;
		NSLog(@"Trying to load page...");
		webView_.delegate = nil;
		webView_ = [[UIWebView alloc] init];
		webView_.delegate = self;
		
		// we fake an old version of the iOS browser to get a correct response.
		// else request does seem to fail on iOS 5 upwards unless we're on an actual iPhone device. Weird.
		//NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16", @"UserAgent", nil];
		//[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
		
		[webView_ loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", _videoItemVO.youtube_id]]]];
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		return YES;
	}
	return NO;
}

- (void)cleanup_ {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[webView_ stopLoading];
	webView_.delegate = nil;
	webView_ = nil;
	retryCount_ = 0;
	domWaitCounter_ = 0;
}

#pragma mark - Notification handlers
-(void)_videoDuration:(NSNotification *)notification {
	NSLog(@"----[AIRPLAY[%d]]----", ![SNAppDelegate hasAirplay]);
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:_index] fadeOutImage];
	
	_pauseButton.hidden = NO;
	_playButton.hidden = YES;
}

-(void)_videoStalled:(NSNotification *)notification {
	_playButton.hidden = NO;
	_pauseButton.hidden = YES;
}

-(void)_videoResumed:(NSNotification *)notification {
	_pauseButton.hidden = NO;
	_playButton.hidden = YES;
}

-(void)_videoEnded:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_VIDEO" object:nil];
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:_index] fadeInImage];
}

-(void)_itemDetailsScroll:(NSNotification *)notification {
	float offset = [[notification object] floatValue];
	_videoPlayerViewController.view.frame = CGRectMake(_videoPlayerViewController.view.frame.origin.x, -offset, _videoPlayerViewController.view.frame.size.width, _videoPlayerViewController.view.frame.size.height);
	_overlayHolderView.frame = CGRectMake(_overlayHolderView.frame.origin.x, -offset, _overlayHolderView.frame.size.width, _overlayHolderView.frame.size.height);
}



#pragma mark - WebView Delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	BOOL should = YES;
	NSURL *url = [request URL];
	NSString *scheme = [url scheme];
	
	NSLog(@"shouldStartLoadWithRequest:[%@][%@]", scheme, url);
	
	//	NSMutableURLRequest *request2 = (NSMutableURLRequest *)request;
	//	if ([request2 respondsToSelector:@selector(setValue:forHTTPHeaderField:)])
	//		[request2 setValue:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16" forHTTPHeaderField:@"User-Agent"];
	
	// Check for DOM load message
	if ([scheme isEqualToString:@"x-sswebview"]) {
		NSString *host = [url host];
		if ([host isEqualToString:@"dom-loaded"]) {
			NSLog(@"DOM load detected!");
			dispatch_async(dispatch_get_main_queue(), ^{
				[self DOMLoaded_];
			});
		}
		return NO;
	}
	
	// Only load http or http requests if delegate doesn't care
	else {
		should = [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
	}
	
	// Stop if we shouldn't load it
	if (should == NO) {
		return NO;
	}
	
	// Starting a new request
	//if ([[request mainDocumentURL] isEqual:[lastRequest_ mainDocumentURL]] == NO) {
	//	lastRequest_ = request;
	testedDOM_ = NO;
	//}
	
	return should;
}


-(void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webViewDidStartLoad");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"webViewDidFinishLoad");
	
	//	if (!selfReference_) {
	//		return;
	//	}
	
	
	// Check DOM
	if (testedDOM_ == NO) {
		testedDOM_ = YES;
		
		// The internal delegate will intercept this load and forward the event to the real delegate
		// Crazy javascript from http://dean.edwards.name/weblog/2006/06/again
		static NSString *testDOM = @"var _SSWebViewDOMLoadTimer=setInterval(function(){if(/loaded|complete/.test(document.readyState)){clearInterval(_SSWebViewDOMLoadTimer);location.href='x-sswebview://dom-loaded'}},10);";
		[webView_ stringByEvaluatingJavaScriptFromString:testDOM];        
	}
	
	// add watchdog in case DOM never get initialized
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(DOMLoaded_) object:nil];
	[self performSelector:@selector(DOMLoaded_) withObject:nil afterDelay:kWatchdogDelay];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {	
	NSLog(@"didFailLoadWithError");
	
	 
	 NSURL *errorURL = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
	 if ([[errorURL absoluteString] rangeOfString:@"poswidget"].length) {
	 NSLog(@"ignoring error: %@", error);
	 return; // ignore those errors
	 }
	 
	 NSLog(@"didFailLoadWithError: %@", error);
	 
	 // give system a little bit more time, may be an irrelevant error
	 [NSObject cancelPreviousPerformRequestsWithTarget:self];
	 [self performSelector:@selector(DOMFailed_:) withObject:error afterDelay:kWatchdogDelay/3];
}



#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	_videoPlayerViewController.view.frame = CGRectMake((-((int)scrollView.contentOffset.x % (int)self.view.frame.size.width)) + ((int)(scrollView.contentOffset.x < _lastOffset) * self.view.frame.size.width), 0.0, self.view.frame.size.width, 180.0);
	_lastOffset = scrollView.contentOffset.x;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	int ind = 0;
	for (SNPlayingVideoItemView_iPhone *videoItemView in _views) {
		if (ind != _index)
			[videoItemView fadeInImage];
		
		ind++;
	}
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:[_videoItems objectAtIndex:(scrollView.contentOffset.x / self.view.frame.size.width)]];	
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:_index] resetScroll];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:[_videoItems objectAtIndex:(scrollView.contentOffset.x / self.view.frame.size.width)]];	
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[_paginationView updToPage:(int)(_scrollView.contentOffset.x / self.view.frame.size.width)];
	
	if ((int)(scrollView.contentOffset.x / self.view.frame.size.width) != _index) {
		_index = (scrollView.contentOffset.x / self.view.frame.size.width);
		
		_videoPlayerViewController.view.frame = CGRectMake((-((int)scrollView.contentOffset.x % (int)self.view.frame.size.width)), 0.0, self.view.frame.size.width, 180.0);
		[_videoPlayerViewController.mpc stop];
		_videoItemVO = (SNVideoItemVO *)[_videoItems objectAtIndex:_index];
		
		_playButton.hidden = YES;
		_pauseButton.hidden = NO;
		
		[self cleanup_];
		[self doRetry_];
	}
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	//NSLog(@"SNChannelGridViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedVideos = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			_videoItems = [[NSMutableArray alloc] init];
			_views = [[NSMutableArray alloc] init];
			
			int tot = 0;
			for (NSDictionary *serverVideo in parsedVideos) {
				SNVideoItemVO *vo = [SNVideoItemVO videoItemWithDictionary:serverVideo];
				
				//NSLog(@"VIDEO \"%@\"", vo.video_title);
				
				if (vo != nil)
					[_videoItems addObject:vo];
				
				SNPlayingVideoItemView_iPhone *videoItemView = [[[SNPlayingVideoItemView_iPhone alloc] initWithFrame:CGRectMake(tot * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) withVO:vo] autorelease];
				[_views addObject:videoItemView];
				tot++;
			}
			
			//_videoItems = [videoList retain];
			_scrollView.contentSize = CGSizeMake(self.view.frame.size.width * tot, self.view.frame.size.height);
			
			for (SNPlayingVideoItemView_iPhone *videoItemView in _views)
				[_scrollView addSubview:videoItemView];
			
			[self _resetMe];
			
			_paginationView = [[SNPaginationView alloc] initWithTotal:[_views count] coords:CGPointMake(160.0, 450.0)];
			[self.view addSubview:_paginationView];			
			
			_videoItemVO = (SNVideoItemVO *)[_videoItems objectAtIndex:0];
			
			[self doRetry_];
			//[_webView loadHTMLString:[NSString stringWithFormat:_htmlString, ((SNVideoItemVO *)[_videoItems objectAtIndex:0]).youtube_id] baseURL:nil];
		}			
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	
	if (request == _videosRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}


@end
