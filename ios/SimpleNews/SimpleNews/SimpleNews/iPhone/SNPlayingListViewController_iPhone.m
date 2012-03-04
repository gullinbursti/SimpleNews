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

@implementation SNPlayingListViewController_iPhone

-(id)initWithVideos:(NSMutableArray *)videos {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		_videoItems = videos;
		_views = [[NSMutableArray alloc] init];
	}
	
	return (self);
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
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
	
	_playPauseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_playPauseButton.frame = CGRectMake(290.0, 450.0, 20.0, 20.0);
	[_playPauseButton setBackgroundColor:[UIColor whiteColor]];
	[_playPauseButton addTarget:self action:@selector(_goPlayPause) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_playPauseButton];
	
	_backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_backButton.frame = CGRectMake(0.0, 0.0, 35.0, 35.0);
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateHighlighted];
	[_backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_backButton];

}

-(void)viewDidLoad {
	[super viewDidLoad];
}


-(void)viewDidUnload {
	[super viewDidUnload];
}


-(void)offsetAtIndex:(int)ind {
	_scrollView.contentOffset = CGPointMake(ind * 320.0, 0.0);
	
	_backButton.frame = CGRectMake(-_backButton.frame.size.width, -_backButton.frame.size.height, _backButton.frame.size.width, _backButton.frame.size.height);
	_playPauseButton.frame = CGRectMake(10.0 + self.view.frame.size.width + _playPauseButton.frame.size.width, 10.0 + self.view.frame.size.height + _playPauseButton.frame.size.height, _playPauseButton.frame.size.width, _playPauseButton.frame.size.height);
	
	[UIView animateWithDuration:0.25 delay:0.33 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		_backButton.frame = CGRectMake(0.0, 0.0, _backButton.frame.size.width, _backButton.frame.size.height);
		_playPauseButton.frame = CGRectMake(290.0, 450.0, _playPauseButton.frame.size.width, _playPauseButton.frame.size.height);
	
	} completion:^(BOOL finished) {
		for (SNPlayingVideoItemView_iPhone *videoItemView in _views)
			[videoItemView introMe];
	}];
}


#pragma mark - Navigation
-(void)_goBack {
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_backButton.frame = CGRectMake(-_backButton.frame.size.width, -_backButton.frame.size.height, _backButton.frame.size.width, _backButton.frame.size.height);
		_playPauseButton.frame = CGRectMake(10.0 + self.view.frame.size.width + _playPauseButton.frame.size.width, 10.0 + self.view.frame.size.height + _playPauseButton.frame.size.height, _playPauseButton.frame.size.width, _playPauseButton.frame.size.height);
	
	} completion:^(BOOL finished) {
		for (SNPlayingVideoItemView_iPhone *videoItemView in _views)
			[videoItemView outroMe];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DETAILS_RETURN" object:nil];
	}];
}

-(void)_goPlayPause {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
}

#pragma mark - Notification handlers
-(void)_videoEnded:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_VIDEO" object:nil];
}

#pragma mark - ScrollView Delegates
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:[_videoItems objectAtIndex:(scrollView.contentOffset.x / self.view.frame.size.width)]];	
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:[_videoItems objectAtIndex:(scrollView.contentOffset.x / self.view.frame.size.width)]];	
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:[_videoItems objectAtIndex:(scrollView.contentOffset.x / self.view.frame.size.width)]];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:[_videoItems objectAtIndex:(scrollView.contentOffset.x / self.view.frame.size.width)]];	
}
@end
