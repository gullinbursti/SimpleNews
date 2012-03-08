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

-(id)initWithVideos:(NSMutableArray *)videos {
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
	
//	int cnt = 0;
//	for (SNVideoItemVO *vo in _videoItems) {
//		SNPlayingVideoItemView_iPhone *videoItemView = [[[SNPlayingVideoItemView_iPhone alloc] initWithFrame:CGRectMake(cnt * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) withVO:vo] autorelease];
//		[_views addObject:videoItemView];
//		[_scrollView addSubview:videoItemView];
//		cnt++;
//	}
	
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

	
	//UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:_videoPlayerViewController] autorelease];
	//[self.navigationController pushViewController:navigationController animated:YES];	
	//[self.navigationController presentModalViewController:_videoPlayerViewController animated:YES];
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
	
	for (SNPlayingVideoItemView_iPhone *videoItemView in _views)
		[videoItemView removeFromSuperview];
	
	_videosRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Channels.php"]]] retain];
	[_videosRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
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
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:0] fadeInImage];
	
	_pauseButton.hidden = YES;
	_playButton.hidden = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_gridButton.frame = CGRectMake(-_gridButton.frame.size.width, -_gridButton.frame.size.height, _gridButton.frame.size.width, _gridButton.frame.size.height);
	
	} completion:^(BOOL finished) {
		[_videoPlayerViewController.mpc stop];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DETAILS_RETURN" object:nil];	
	}];
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
		SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:_index];
		
		_playButton.hidden = YES;
		_pauseButton.hidden = NO;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:vo];	
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];	
	}
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNChannelGridViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
				
				NSLog(@"VIDEO \"%@\"", vo.video_title);
				
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
