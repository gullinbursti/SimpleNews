//
//  SNVideoGridViewController_iPad.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.02.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"

@interface SNVideoGridViewController_iPad : UIViewController <EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	UIScrollView *_scrollView;
	
	UIView *_holderView;
	
	BOOL _isReloading;
	
	NSMutableArray *_videoItems;
	NSMutableArray *_views;
	
	//SNPlayingListViewController_iPhone *_playingListViewController;
	//SNCategoryListView_iPhone *_categoryListView;
	//SNPluginListView_iPhone *_pluginListView;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	CGPoint _offsetPt;
	
	float _scrollOffset;
	
	int _playingIndex;
	
	BOOL _isDetails;
	BOOL _isStore;
	BOOL _isCategories;
}

@end
