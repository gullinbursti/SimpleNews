//
//  SNPlayingListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideoPlayerViewController_iPhone.h"

@interface SNPlayingListViewController_iPhone : UIViewController <UIScrollViewDelegate> {
	
	UIScrollView *_scrollView;
	NSMutableArray *_videoItems;
	NSMutableArray *_views;
	
	int _index;
	
	UIButton *_backButton;
	
	SNVideoPlayerViewController_iPhone *_videoPlayerViewController;
	
	BOOL _isScrollingLeft;
	float _lastOffset;
}

-(id)initWithVideos:(NSMutableArray *)videos;
-(void)offsetAtIndex:(int)ind;

@end
