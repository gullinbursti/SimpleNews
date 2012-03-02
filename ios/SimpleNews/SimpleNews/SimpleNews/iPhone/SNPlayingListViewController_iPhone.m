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
		_videoItems = videos;
	}
	
	return (self);
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	self.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	[self.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.delegate = self;
	_scrollView.opaque = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width * [_videoItems count], self.view.frame.size.height);
	_scrollView.pagingEnabled = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.showsHorizontalScrollIndicator = YES;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	[self.view addSubview:_scrollView];
	
	int cnt = 0;
	for (SNVideoItemVO *vo in _videoItems) {
		SNPlayingVideoItemView_iPhone *videoItemView = [[[SNPlayingVideoItemView_iPhone alloc] initWithFrame:CGRectMake(cnt * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) withVO:vo] autorelease];
		[_scrollView addSubview:videoItemView];
		cnt++;
	}
}

-(void)viewDidLoad {
	[super viewDidLoad];
}


-(void)viewDidUnload {
	[super viewDidUnload];
}


-(void)offsetAtIndex:(int)ind {
	_scrollView.contentOffset = CGPointMake(ind * 320.0, 0.0);
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
}
@end
