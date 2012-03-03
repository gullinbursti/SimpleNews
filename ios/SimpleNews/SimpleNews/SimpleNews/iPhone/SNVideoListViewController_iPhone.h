//
//  SNVideoListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SNActiveListViewController_iPhone.h"
#import "SNVideoDetailsView_iPhone.h"
#import "SNCategoryListView_iPhone.h"
#import "SNPluginListView_iPhone.h"
#import "SNVideoSearchView_iPhone.h"
#import "SNVideoItemView_iPhone.h"
#import "SNPlayingListViewController_iPhone.h"

#import "EGORefreshTableHeaderView.h"

@interface SNVideoListViewController_iPhone : UIViewController <EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	UIUserInterfaceIdiom _userInterfaceIdiom;
	
	UIView *_holderView;
	
	BOOL _isReloading;
	UIScrollView *_scrollView;
	SNActiveListViewController_iPhone *_activeListViewController;
	SNVideoDetailsView_iPhone *_videoDetailsView;
	
	NSMutableArray *_videoItems;
	NSMutableArray *_itemViews;
	
	SNPlayingListViewController_iPhone *_playingListViewController;
	SNCategoryListView_iPhone *_categoryListView;
	SNPluginListView_iPhone *_pluginListView;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	CGPoint _offsetPt;
	
	float _scrollOffset;
	
	int _playingIndex;
	
	BOOL _isDetails;
	BOOL _isStore;
	BOOL _isCategories;
}

-(id)initWithUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;

@end
