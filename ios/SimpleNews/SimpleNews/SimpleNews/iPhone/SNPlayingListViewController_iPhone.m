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
		_isFirstVideo = YES;
		
		_ytVideos = [[NSMutableDictionary alloc] init];
		
		_videosRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Channels.php"]]] retain];
		[_videosRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
		[_videosRequest setPostValue:vo.youtube_id forKey:@"id"];
		[_videosRequest setPostValue:vo.channel_title forKey:@"name"];
		[_videosRequest setTimeOutSeconds:30];
		[_videosRequest setDelegate:self];
		[_videosRequest startAsynchronous];
	}
	
	return (self);
}

-(void)dealloc {
	[_scrollView release];
	[_views release];
	[_channelsButton release];
	[_shareButton release];
	[_playImgView release];
	[_pauseImgView release];
	[_overlayHolderView release];
	[_videoPlayerViewController autorelease];
	[_videoLoadOverlayView release];
	[_paginationView release];
	[_videosRequest release];
	//[_videoItemVO release];
	[_youTubeScraper release];
	[_ytVideos release];
	
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor colorWithWhite:0.196 alpha:1.0]];
	
	_videoPlayerViewController = [[SNVideoPlayerViewController_iPhone alloc] init];
	_videoPlayerViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 180.0);
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
	
	_videoLoadOverlayView = [[UIView alloc] initWithFrame:_videoPlayerViewController.view.frame];
	[_videoLoadOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
	[_overlayHolderView addSubview:_videoLoadOverlayView];
	
	_channelsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_channelsButton.frame = CGRectMake(0.0, 0.0, 34.0, 34.0);
	[_channelsButton setBackgroundImage:[UIImage imageNamed:@"gridButton_nonActive.png"] forState:UIControlStateNormal];
	[_channelsButton setBackgroundImage:[UIImage imageNamed:@"gridButton_Active.png"] forState:UIControlStateHighlighted];
	[_channelsButton addTarget:self action:@selector(_goGrid) forControlEvents:UIControlEventTouchUpInside];
	[_overlayHolderView addSubview:_channelsButton];
	
	_playImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(128.0, 58.0, 64.0, 64.0)] autorelease];
	_playImgView.image = [UIImage imageNamed:@"playButton_nonActive.png"];
	[_overlayHolderView addSubview:_playImgView];
	
	_pauseImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(128.0, 58.0, 64.0, 64.0)] autorelease];
	_pauseImgView.image = [UIImage imageNamed:@"playButton_nonActive.png"];
	[_overlayHolderView addSubview:_pauseImgView];
	
	
	MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(7.0, 147.0, 20.0, 20.0)];
	[volumeView setShowsVolumeSlider:NO];
	[volumeView sizeToFit];
	[_overlayHolderView addSubview:volumeView];
	
	_shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_shareButton.frame = CGRectMake(280.0, 192.0, 34.0, 34.0);
	[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive.png"] forState:UIControlStateNormal];
	[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active.png"] forState:UIControlStateHighlighted];
	[_shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_shareButton];
	
//	UIImageView *hdImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(284.0, 200.0, 34.0, 34.0)] autorelease];
//	hdImgView.image = [UIImage imageNamed:@"hd-icon.png"];
//	[self.view addSubview:hdImgView];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	//NSString *loadHtml;
	//NSString *ytRequest;
	
	NSURLRequest *ytPlayerRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"youtube_player" ofType:@"html"]]];
	
	//NSString *ytEmbedHTML = @"<html><head>\
	<body style=\"margin:0\">\
	<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
	width=\"%0.0f\" height=\"%0.0f\" allowsfullscreen=\"false\"></embed>\
	</body></html>";
	
	// YOUTUBE
	//loadHtml = @"<html><body><object style=\"height: 390px; width: 640px\"><param name=\"movie\" value=\"http://www.youtube.com/v/rGX6szf99KA?version=3&feature=player_detailpage\"><param name=\"allowFullScreen\" value=\"true\"><param name=\"allowScriptAccess\" value=\"always\"><embed src=\"http://www.youtube.com/v/rGX6szf99KA?version=3&feature=player_detailpage\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\" allowScriptAccess=\"always\" width=\"640\" height=\"360\"></object></body></html>";
	//ytRequest = @"http://www.youtube.com/watch?v=rGX6szf99KA";
		
	// YT IFRAME
	//loadHtml = @"<iframe id=\"player\" type=\"text/html\" width=\"320\" height=\"180\" src=\"http://www.youtube.com/embed/u1zgFlCw8Aw?enablejsapi=1&origin=http://example.com\" frameborder=\"0\">";
	
	/*
	_webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 180.0)] autorelease];
	[_webView setBackgroundColor:[UIColor redColor]];
	_webView.delegate = self;
	_webView.allowsInlineMediaPlayback = YES;
	_webView.mediaPlaybackRequiresUserAction = NO;
	[_webView loadRequest:ytPlayerRequest];	
	//[_webView loadHTMLString:[NSString stringWithFormat:ytEmbedHTML, ytRequest, webView.frame.size.width, webView.frame.size.height] baseURL:nil];
	//[_webView loadHTMLString:loadHtml baseURL:nil];
	[self.view addSubview:_webView];
	 */
}

-(void)viewDidLoad {
	[super viewDidLoad];
}


-(void)viewDidUnload {
	[super viewDidUnload];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == _overlayHolderView) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
		return;
	}
}


-(void)_resetMe {
	_pauseImgView.hidden = YES;
	_playImgView.hidden = YES;
	
	_index = 0;
	
	_scrollView.contentOffset = CGPointMake(_index * 320.0, 0.0);
	_channelsButton.frame = CGRectMake(0.0, 0.0, _channelsButton.frame.size.width, _channelsButton.frame.size.height);
	_videoPlayerViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 180.0);
	[_paginationView updToPage:(int)(_scrollView.contentOffset.x / self.view.frame.size.width)];
	
	[UIView animateWithDuration:0.15 delay:0.33 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		_overlayHolderView.frame = CGRectMake(0.0, 0.0, _overlayHolderView.frame.size.width, _overlayHolderView.frame.size.height);
		_shareButton.frame = CGRectMake(_shareButton.frame.origin.x, 192.0, _shareButton.frame.size.width, _shareButton.frame.size.height);
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


#pragma mark - Navigation
-(void)_goGrid {
	[_youTubeScraper destroyMe];
	[_videoPlayerViewController.mpc stop];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DETAILS_RETURN" object:nil];	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goShare {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"video url", @"twitter", @"cancel", nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

-(void)_goPlay {
	_pauseImgView.hidden = YES;
	_playImgView.hidden = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
}

-(void)_goPause {
	_pauseImgView.hidden = YES;
	_playImgView.hidden = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
}


#pragma mark - Notification handlers
-(void)_videoDuration:(NSNotification *)notification {
	NSLog(@"----[AIRPLAY[%d]]----", ![SNAppDelegate hasAirplay]);
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:_index] fadeOutImage];
	
	_pauseImgView.hidden = YES;
	_playImgView.hidden = YES;
}

-(void)_videoStalled:(NSNotification *)notification {
	_pauseImgView.hidden = YES;
	_playImgView.hidden = YES;
}

-(void)_videoResumed:(NSNotification *)notification {
	_pauseImgView.hidden = YES;
	_playImgView.hidden = YES;
}

-(void)_videoEnded:(NSNotification *)notification {
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:_index] fadeInImage];
	_index++;
	
	NSLog(@"SCROLLVIEW:[%f]", _scrollView.contentOffset.x);
	
	[self _resetMe];
	//_videoItemVO = (SNVideoItemVO *)[_videoItems objectAtIndex:_index];
	//[_youTubeScraper setYtID:_videoItemVO.youtube_id];
	
	//_playButton.hidden = YES;
	//_pauseButton.hidden = YES;
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_videoLoadOverlayView.alpha = 1.0;
//	}];
//_scrollView.contentOffset = CGPointMake(320.0, 0.0);
}

-(void)_itemDetailsScroll:(NSNotification *)notification {
	float offset = [[notification object] floatValue];

	_videoPlayerViewController.view.frame = CGRectMake(_videoPlayerViewController.view.frame.origin.x, -offset, _videoPlayerViewController.view.frame.size.width, _videoPlayerViewController.view.frame.size.height);
	_overlayHolderView.frame = CGRectMake(_overlayHolderView.frame.origin.x, -offset, _overlayHolderView.frame.size.width, _overlayHolderView.frame.size.height);
	_shareButton.frame = CGRectMake(_shareButton.frame.origin.x, 192.0 - offset, _shareButton.frame.size.width, _shareButton.frame.size.height);
}


#pragma mark - YouTubeScraper Delegates
-(void)snYouTubeScraperDidExtractMP4:(NSString *)url forYouTubeID:(NSString *)ytID{
	NSLog(@"RETRIEVED URL:[%@] (%@)", ytID, url);
	
	[_ytVideos setObject:url forKey:ytID];
	NSLog(@"YOUTUBE VIDEOS:[%@]", _ytVideos);
	
	//if (_isFirstVideo) {
		_isFirstVideo = NO;
		[UIView animateWithDuration:0.25 animations:^(void) {
			_videoLoadOverlayView.alpha = 0.0;
	
		} completion:^(BOOL finished) {
		}];
	
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:url];
	//}
}

-(void)snYouTubeScraperFinshedQueue {
	NSLog(@"SCRAPER QUEUE FINISHED");
}

#pragma mark ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/#/watch?v=", _videoItemVO.youtube_id]]];
			break;
			
		case 1:
			break;
			
		case 2:
			break;
	}
}

#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	_videoPlayerViewController.view.frame = CGRectMake((-((int)scrollView.contentOffset.x % (int)self.view.frame.size.width)) + ((int)(scrollView.contentOffset.x < _lastOffset) * self.view.frame.size.width), 0.0, self.view.frame.size.width, 180.0);
	_lastOffset = scrollView.contentOffset.x;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	int ind = 0;
	for (SNPlayingVideoItemView_iPhone *videoItemView in _views) {
		if (ind != _index) {
			[videoItemView fadeInImage];
		}
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
		
		[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeVideo('%@');", _videoItemVO.youtube_id]];
		
		[_youTubeScraper setYtID:_videoItemVO.youtube_id];
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:nil];
		
		_pauseImgView.hidden = YES;
		_playImgView.hidden = YES;
		[UIView animateWithDuration:0.25 animations:^(void) {
			_videoLoadOverlayView.alpha = 1.0;
		}];
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
			NSMutableArray *ytIDs = [NSMutableArray array];
			
			_views = [NSMutableArray new];
			
			int tot = 0;
			for (NSDictionary *serverVideo in parsedVideos) {
				SNVideoItemVO *vo = [SNVideoItemVO videoItemWithDictionary:serverVideo];
				
				//NSLog(@"VIDEO \"%@\"", vo.video_title);
				
				if (vo != nil) {
					[videoList addObject:vo];
					[ytIDs addObject:vo.youtube_id];
				}
				
				SNPlayingVideoItemView_iPhone *videoItemView = [[[SNPlayingVideoItemView_iPhone alloc] initWithFrame:CGRectMake(tot * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) withVO:vo] autorelease];
				[_views addObject:videoItemView];
				tot++;
			}
			
			_videoItems = [videoList retain];
			//[videoList release];
			_scrollView.contentSize = CGSizeMake(self.view.frame.size.width * tot, self.view.frame.size.height);
			
			for (SNPlayingVideoItemView_iPhone *videoItemView in _views)
				[_scrollView addSubview:videoItemView];
			
			[self _resetMe];
			
			_paginationView = [[SNPaginationView alloc] initWithTotal:[_views count] coords:CGPointMake(160.0, 450.0)];
			[self.view addSubview:_paginationView];			
			
			_videoItemVO = (SNVideoItemVO *)[_videoItems objectAtIndex:0];
			//_youTubeScraper = [[SNYouTubeScraper alloc] initWithYouTubeIDs:ytIDs];
			_youTubeScraper = [[SNYouTubeScraper alloc] initWithYouTubeID:_videoItemVO.youtube_id];
			_youTubeScraper.delegate = self;
			[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeVideo('%@');", _videoItemVO.youtube_id]];
			
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:nil];
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




#pragma mark - WebView delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *urlString = [[request URL] absoluteString];
	
	if ([urlString hasPrefix:@"result:"]) {
		NSArray *pathComponents = [[[request URL] path] pathComponents];
		
		NSString *key = [pathComponents objectAtIndex:1];
		NSString *value = [pathComponents objectAtIndex:2];
		
		//NSLog(@"['%@'] = \"%@\"", key, value);
		
		if ([key isEqualToString:@"duration"]) {
			//_duration = [value floatValue];
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_DURATION" object:[NSNumber numberWithFloat:_duration]];
			
		} else if ([key isEqualToString:@"time"]) {
			//float currTime = [value floatValue];
			
			//if (_duration > 0.0) {
			//	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_TIME" object:[NSNumber numberWithFloat:currTime]];
			//}
			
		} else if ([key isEqualToString:@"state"]) {
			if ([value isEqualToString:@"ENDED"]) {
				//_isFinished = YES;
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
