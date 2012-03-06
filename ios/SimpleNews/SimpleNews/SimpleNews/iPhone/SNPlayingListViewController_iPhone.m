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

@implementation SNPlayingListViewController_iPhone

-(id)initWithVideos:(NSMutableArray *)videos {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoDuration:) name:@"VIDEO_DURATION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemDetailsScroll:) name:@"ITEM_DETAILS_SCROLL" object:nil];
		
		_videoItems = videos;
		_views = [[NSMutableArray alloc] init];
		_lastOffset = 0.0;
		_index = 0;
	}
	
	return (self);
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
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
	
	int cnt = 0;
	for (SNVideoItemVO *vo in _videoItems) {
		SNPlayingVideoItemView_iPhone *videoItemView = [[[SNPlayingVideoItemView_iPhone alloc] initWithFrame:CGRectMake(cnt * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) withVO:vo] autorelease];
		[_views addObject:videoItemView];
		[_scrollView addSubview:videoItemView];
		cnt++;
	}
		
	_backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_backButton.frame = CGRectMake(0.0, 0.0, 35.0, 35.0);
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateHighlighted];
	[_backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_backButton];
	
	
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


-(void)offsetAtIndex:(int)ind {
	_index = ind;
	
	//SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:_index];
	
	_scrollView.contentOffset = CGPointMake(_index * 320.0, 0.0);	
	_backButton.frame = CGRectMake(-_backButton.frame.size.width, -_backButton.frame.size.height, _backButton.frame.size.width, _backButton.frame.size.height);
	
	[UIView animateWithDuration:0.25 delay:0.33 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		_backButton.frame = CGRectMake(0.0, 0.0, _backButton.frame.size.width, _backButton.frame.size.height);
	
	} completion:nil];
}


#pragma mark - Navigation
-(void)_goBack {
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_backButton.frame = CGRectMake(-_backButton.frame.size.width, -_backButton.frame.size.height, _backButton.frame.size.width, _backButton.frame.size.height);
	
	} completion:nil];
}

-(void)_goPlayPause {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
}

#pragma mark - Notification handlers
-(void)_videoDuration:(NSNotification *)notification {
	NSLog(@"----[AIRPLAY[%d]]----", ![SNAppDelegate hasAirplay]);
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:_index] fadeOutImage];
}

-(void)_videoEnded:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_VIDEO" object:nil];
	[(SNPlayingVideoItemView_iPhone *)[_views objectAtIndex:_index] fadeInImage];
}

-(void)_itemDetailsScroll:(NSNotification *)notification {
	//float offset = [[notification object] floatValue];
	//_videoPlayerViewController.view.frame = CGRectMake(_videoPlayerViewController.view.frame.origin.x, -offset, _videoPlayerViewController.view.frame.size.width, _videoPlayerViewController.view.frame.size.height);
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (scrollView.contentOffset.x < _lastOffset)
		_isScrollingLeft = YES;
	
	else
		_isScrollingLeft = NO;
	
	_lastOffset = scrollView.contentOffset.x;
	_videoPlayerViewController.view.frame = CGRectMake((-((int)scrollView.contentOffset.x % (int)self.view.frame.size.width)) + ((int)_isScrollingLeft * self.view.frame.size.width), 0.0, self.view.frame.size.width, 180.0);
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
	[_videoPlayerViewController.mpc stop];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ((int)(scrollView.contentOffset.x / self.view.frame.size.width) != _index) {
		_index = (scrollView.contentOffset.x / self.view.frame.size.width);
		
		_videoPlayerViewController.view.frame = CGRectMake((-((int)scrollView.contentOffset.x % (int)self.view.frame.size.width)), 0.0, self.view.frame.size.width, 180.0);
		//SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:_index];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:[_videoItems objectAtIndex:_index]];	
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:[_videoItems objectAtIndex:_index]];	
	}
	
}
@end
