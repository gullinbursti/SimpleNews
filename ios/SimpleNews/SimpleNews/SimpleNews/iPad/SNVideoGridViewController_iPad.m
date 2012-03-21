//
//  SNVideoGridViewController_iPad.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.02.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoGridViewController_iPad.h"

#import "SNVideoItemVO.h"
#import "SNVideoItemView_iPad.h"

@implementation SNVideoGridViewController_iPad

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_airplayBack:) name:@"AIRPLAY_BACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_detailsReturn:) name:@"DETAILS_RETURN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoDuration:) name:@"VIDEO_DURATION" object:nil];
		
		_videoItems = [NSMutableArray new];
		_views = [NSMutableArray new];
		_isDetails = NO;
		_isStore = NO;
		_scrollOffset = 0;
		
		//NSLog(@"USER INTERFACE:[%d]", _userInterfaceIdiom); 0 == iPhone // 1 == iPad
		
		NSString *testVideoItemsPath = [[NSBundle mainBundle] pathForResource:@"video_items" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testVideoItemsPath] options:NSPropertyListImmutable format:nil error:nil];
		
		for (NSDictionary *testVideoItem in plist)
			[_videoItems addObject:[SNVideoItemVO videoItemWithDictionary:testVideoItem]];
		
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO_PLAYBACK" object:((SNVideoItemVO *)[_videoItems objectAtIndex:0]).video_url];
	}
	
	return (self);
}

-(void)dealloc {
	[_scrollView release];
	
	[super dealloc];
}


-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	_holderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_holderView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - _holderView.frame.origin.y)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = YES;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = self.view.frame.size;
	_scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
	[_holderView addSubview:_scrollView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -_scrollView.bounds.size.height, self.view.frame.size.width, _scrollView.bounds.size.height)];
	_refreshHeaderView.delegate = self;
	[_scrollView addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
	
	
	int tot = 0;
	for (SNVideoItemVO *vo in _videoItems) {
		SNVideoItemView_iPad *itemView = [[[SNVideoItemView_iPad alloc] initWithFrame:CGRectMake(256.0 * (tot % 3), 256 * (int)(tot / 3), 256.0, 256.0) videoItemVO:vo] autorelease];
		[_views addObject:itemView];		
		[_scrollView addSubview:itemView];
		
		//NSLog(@"VIDEO ITEM:[%d] \"%@\"", vo.video_id, vo.video_title);
		tot++;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 200.0 * tot);
	
	/*
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[_holderView addGestureRecognizer:panRecognizer];
	*/
	
//	_videoDetailsView = [[SNVideoDetailsView_iPhone alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
//	[self.view addSubview:_videoDetailsView];
//	
//	_optionsListView = [[SNOptionsListView_iPhone alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
//	[self.view addSubview:_optionsListView];
	
	
	//NSString *loadHtml;
	//NSString *ytRequest;
	
	
	//NSString *youTubeVideoHTML = @"<html><head>\
	<body style=\"margin:0\">\
	<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
	width=\"%0.0f\" height=\"%0.0f\"></embed>\
	</body></html>";
	
	// CNN
	//loadHtml = @"<html><body><object width=\"416\" height=\"374\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" id=\"ep\"><param name=\"allowfullscreen\" value=\"true\" /><param name=\"allowscriptaccess\" value=\"always\" /><param name=\"wmode\" value=\"transparent\" /><param name=\"movie\" value=\"http://i.cdn.turner.com/cnn/.element/apps/cvp/3.0/swf/cnn_416x234_embed.swf?context=embed&videoId=showbiz/2012/03/10/bts-ray-j-speaks-whitney-houston.cnn\" /><param name=\"bgcolor\" value=\"#000000\" /><embed src=\"http://i.cdn.turner.com/cnn/.element/apps/cvp/3.0/swf/cnn_416x234_embed.swf?context=embed&videoId=showbiz/2012/03/10/bts-ray-j-speaks-whitney-houston.cnn\" type=\"application/x-shockwave-flash\" bgcolor=\"#000000\" allowfullscreen=\"true\" allowscriptaccess=\"always\" width=\"416\" wmode=\"transparent\" height=\"374\"></embed></object></body></html>";
	
	// YOUTUBE
	//loadHtml = @"<html><body><object style=\"height: 390px; width: 640px\"><param name=\"movie\" value=\"http://www.youtube.com/v/rGX6szf99KA?version=3&feature=player_detailpage\"><param name=\"allowFullScreen\" value=\"true\"><param name=\"allowScriptAccess\" value=\"always\"><embed src=\"http://www.youtube.com/v/rGX6szf99KA?version=3&feature=player_detailpage\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\" allowScriptAccess=\"always\" width=\"640\" height=\"360\"></object></body></html>";
	//ytRequest = @"http://www.youtube.com/watch?v=rGX6szf99KA";
	
	// ABC
	//loadHtml = @"<html><body><object name=\"kaltura_player_1331345891\" id=\"kaltura_player_1331345891\" type=\"application/x-shockwave-flash\" allowScriptAccess=\"always\" allowNetworking=\"all\" allowFullScreen=\"true\" height=\"221\" width=\"392\" data=\"http://cdnapi.kaltura.com/index.php/kwidget/wid/0_071vwvlx/uiconf_id/6501231\"> \
	<param name=\"allowScriptAccess\" value=\"always\"/> \
	<param name=\"allowNetworking\" value=\"all\"/> \
	<param name=\"allowFullScreen\" value=\"true\"/> \
	<param name=\"bgcolor\" value=\"#000000\"/> \
	<param name=\"movie\" value=\"http://cdnapi.kaltura.com/index.php/kwidget/wid/0_071vwvlx/uiconf_id/6501231\"/> \
	<param name=\"flashVars\" value=\"referer=http://abcnews.go.com/WNT/video/pink-slime-15873068&autoPlay=false\"/> \
	<a href=\"http://corp.kaltura.com\">video platform</a> \
	<a href=\"http://corp.kaltura.com/video_platform/video_management\">video management</a> \
	<a href=\"http://corp.kaltura.com/solutions/video_solution\">video solutions</a> \
	<a href=\"http://corp.kaltura.com/video_platform/video_publishing\">video player</a> \
	</object></body></html>";
	//[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ytRequest]]];
	
	//loadHtml = @"<iframe id=\"player\" type=\"text/html\" width=\"320\" height=\"180\" src=\"http://www.youtube.com/embed/u1zgFlCw8Aw?enablejsapi=1&origin=http://example.com\" frameborder=\"0\">";
	
	//UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 180.0)] autorelease];
	//NSURLRequest *ytPlayerRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"youtube_player" ofType:@"html"]]];
	
	//[webView setBackgroundColor:[UIColor redColor]];
	//webView.delegate = self;
	//webView.allowsInlineMediaPlayback = YES;
	//webView.mediaPlaybackRequiresUserAction = NO;
	//[webView loadHTMLString:[NSString stringWithFormat:youTubeVideoHTML, ytRequest, webView.frame.size.width, webView.frame.size.height] baseURL:nil];
	//[webView loadRequest:ytPlayerRequest];	
	//[webView loadHTMLString:loadHtml baseURL:nil];
	//[self.view addSubview:webView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}



#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}



-(void)_reloadData {
	_isReloading = YES;	
}

-(void)_doneLoadingData {
	_isReloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}


-(void)_resetToTop {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_scrollView.contentOffset = CGPointMake(0.0, 55.0);
	}];
}


#pragma mark EGORefreshTableHeaderDelegate Methods
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	
	//[self reloadData];
	[self performSelector:@selector(_doneLoadingData) withObject:nil afterDelay:1.33];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return (_isReloading); // should return if data source model is reloading
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}



-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSLog(@"ORIENTATION:[%d]", interfaceOrientation);
	//return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
	return (YES);
}

@end
