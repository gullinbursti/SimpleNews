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
-(void)_cleanupScraper;
-(BOOL)_goRetryScrape;
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
		
		_views = [[NSMutableArray alloc] init];
		_lastOffset = 0.0;
		_index = 0;
		
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

-(void)dealloc {
	[_videoPlayerViewController release];
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
	
	_overlayHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 180.0)];
	[self.view addSubview:_overlayHolderView];
	
	_gridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_gridButton.frame = CGRectMake(8.0, 8.0, 14.0, 14.0);
	[_gridButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive.png"] forState:UIControlStateNormal];
	[_gridButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active.png"] forState:UIControlStateHighlighted];
	[_gridButton addTarget:self action:@selector(_goGrid) forControlEvents:UIControlEventTouchUpInside];
	[_overlayHolderView addSubview:_gridButton];
	
	_shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_shareButton.frame = CGRectMake(280.0, 195.0, 34.0, 34.0);
	[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive.png"] forState:UIControlStateNormal];
	[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active.png"] forState:UIControlStateHighlighted];
	[_shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[_overlayHolderView addSubview:_shareButton];
	
	_playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_playButton.frame = CGRectMake(17.0, 110.0, 64.0, 64.0);
	_playButton.hidden = YES;
	[_playButton setBackgroundImage:[UIImage imageNamed:@"playButton_nonActive.png"] forState:UIControlStateNormal];
	[_playButton setBackgroundImage:[UIImage imageNamed:@"playButton_Active.png"] forState:UIControlStateHighlighted];
	[_playButton addTarget:self action:@selector(_goPlay) forControlEvents:UIControlEventTouchUpInside];
	//[_overlayHolderView addSubview:_playButton];
	
	_pauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_pauseButton.frame = CGRectMake(17.0, 110.0, 64.0, 64.0);
	[_pauseButton setBackgroundImage:[UIImage imageNamed:@"pauseButton_nonActive.png"] forState:UIControlStateNormal];
	[_pauseButton setBackgroundImage:[UIImage imageNamed:@"pauseButton_Active.png"] forState:UIControlStateHighlighted];
	[_pauseButton addTarget:self action:@selector(_goPause) forControlEvents:UIControlEventTouchUpInside];
	//[_overlayHolderView addSubview:_pauseButton];
	
	MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(270.0, 17.0, 40.0, 20.0)];
	[volumeView setShowsVolumeSlider:NO];
	[volumeView sizeToFit];
	[_overlayHolderView addSubview:volumeView];
	
//	UIImageView *hdImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(284.0, 200.0, 34.0, 34.0)] autorelease];
//	hdImgView.image = [UIImage imageNamed:@"hd-icon.png"];
//	[self.view addSubview:hdImgView];
	
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
	_gridButton.frame = CGRectMake(8.0, 8.0, _gridButton.frame.size.width, _gridButton.frame.size.height);
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
	[_videosRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[_videosRequest setPostValue:vo.youtube_id forKey:@"id"];
	[_videosRequest setPostValue:vo.channel_title forKey:@"name"];
	[_videosRequest setTimeOutSeconds:30];
	[_videosRequest setDelegate:self];
	[_videosRequest startAsynchronous];
}


#pragma mark - Navigation
-(void)_goGrid {
	[self _cleanupScraper];
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


-(void)_loadedDOM {
	
	// figure out if we can extract the youtube url!
	NSString *youTubeMP4URL = [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video')[0].getAttribute('src')"];
	NSLog(@"testing dom. query: %@", youTubeMP4URL);
	
	if ([youTubeMP4URL hasPrefix:@"http"]) {
		NSLog(@"Finished extracting: %@", youTubeMP4URL);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:youTubeMP4URL];
		[self _cleanupScraper];
		
	} else {
		if (_domWaitCounter < kExtraDOMDelay * 4) {
			_domWaitCounter++;
			[self performSelector:@selector(_loadedDOM) withObject:nil afterDelay:0.25f]; // try often!
			
			return;
		}
		
		if (![self _goRetryScrape]) {
			//NSError *error = [NSError errorWithDomain:@"com.sparklemountain.simplenews" code:100 userInfo:[NSDictionary dictionaryWithObject:@"MP4 URL could not be found." forKey:NSLocalizedDescriptionKey]];
			//if (failureBlock_) {
			//	failureBlock_(error);
			//}
			[self _cleanupScraper];
		}
	}
}

- (void)_failedDOM:(NSError *)error {
	if (![self _goRetryScrape]) {
		NSLog(@"FAILED!!!");
		
		[self _cleanupScraper];
	}
}


- (BOOL)_goRetryScrape {
	NSLog(@"_goRetryScrape");
	
	if ((_retryCount <= kMaxNumberOfRetries + 1)) {
		_retryCount++;
		_domWaitCounter = 0;
		
		_webView.delegate = nil;
		_webView = [[UIWebView alloc] init];
		_webView.delegate = self;
		
		[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", _videoItemVO.youtube_id]]]];
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		
		return (YES);
	}
	return (NO);
}

- (void)_cleanupScraper {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[_webView stopLoading];
	_webView.delegate = nil;
	_webView = nil;
	_retryCount = 0;
	_domWaitCounter = 0;
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
	
	_index++;
	
}

-(void)_itemDetailsScroll:(NSNotification *)notification {
	float offset = [[notification object] floatValue];
	_videoPlayerViewController.view.frame = CGRectMake(_videoPlayerViewController.view.frame.origin.x, -offset, _videoPlayerViewController.view.frame.size.width, _videoPlayerViewController.view.frame.size.height);
	_overlayHolderView.frame = CGRectMake(_overlayHolderView.frame.origin.x, -offset, _overlayHolderView.frame.size.width, _overlayHolderView.frame.size.height);
}



#pragma mark - WebView Delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	BOOL shouldLoad = YES;
	NSURL *url = [request URL];
	NSString *scheme = [url scheme];
	
	// Check for DOM load message
	if ([scheme isEqualToString:@"x-sswebview"]) {
		NSString *host = [url host];
		
		if ([host isEqualToString:@"dom-loaded"]) {
			NSLog(@"DOM load detected!");
			dispatch_async(dispatch_get_main_queue(), ^{
				[self _loadedDOM];
			});
		}
		
		return (NO);
	}
	
	else
		shouldLoad = [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
	
	
	if (shouldLoad == NO)
		return (NO);
	
	_isDOMTested = NO;
	
	return (shouldLoad);
}


-(void)webViewDidStartLoad:(UIWebView *)webView {

}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
	
	// Check DOM
	if (_isDOMTested == NO) {
		_isDOMTested = YES;
		
		// The internal delegate will intercept this load and forward the event to the real delegate
		[_webView stringByEvaluatingJavaScriptFromString:@"var _SSWebViewDOMLoadTimer=setInterval(function(){if(/loaded|complete/.test(document.readyState)){clearInterval(_SSWebViewDOMLoadTimer);location.href='x-sswebview://dom-loaded'}},10);"];        
	}
	
	// add watchdog in case DOM never get initialized
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_loadedDOM) object:nil];
	[self performSelector:@selector(_loadedDOM) withObject:nil afterDelay:kWatchdogDelay];
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
	[self performSelector:@selector(_failedDOM:) withObject:error afterDelay:kWatchdogDelay / 3];
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
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:_index] resetScroll];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
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
		
		[self _cleanupScraper];
		[self _goRetryScrape];
	}
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNPlayingListViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedVideos = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *videoList = [NSMutableArray array];
			_views = [NSMutableArray new];
			
			int tot = 0;
			for (NSDictionary *serverVideo in parsedVideos) {
				SNVideoItemVO *vo = [SNVideoItemVO videoItemWithDictionary:serverVideo];
				
				//NSLog(@"VIDEO \"%@\"", vo.video_title);
				
				if (vo != nil)
					[videoList addObject:vo];
				
				SNPlayingVideoItemView_iPhone *videoItemView = [[[SNPlayingVideoItemView_iPhone alloc] initWithFrame:CGRectMake(tot * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) withVO:vo] autorelease];
				[_views addObject:videoItemView];
				tot++;
			}
			
			_videoItems = [videoList retain];
			_scrollView.contentSize = CGSizeMake(self.view.frame.size.width * tot, self.view.frame.size.height);
			
			for (SNPlayingVideoItemView_iPhone *videoItemView in _views)
				[_scrollView addSubview:videoItemView];
			
			[self _resetMe];
			
			_paginationView = [[SNPaginationView alloc] initWithTotal:[_views count] coords:CGPointMake(160.0, 450.0)];
			[self.view addSubview:_paginationView];			
			
			_videoItemVO = (SNVideoItemVO *)[_videoItems objectAtIndex:0];
			[self _goRetryScrape];
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
