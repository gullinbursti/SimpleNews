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
#import "SNCategoryListView_iPhone.h"
#import "SNVideoSearchView_iPhone.h"
#import "SNVideoItemView_iPhone.h"

#import "EGORefreshTableHeaderView.h"

@interface SNVideoListViewController_iPhone : UIViewController <EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	UIUserInterfaceIdiom _userInterfaceIdiom;
	
	UIView *_holderView;
	UIScrollView *_scrollView;
	SNActiveListViewController_iPhone *_activeListViewController;
	
	NSMutableArray *_videoItems;
	NSMutableArray *_itemViews;
	
	BOOL _isSwiped;
	SNCategoryListView_iPhone *_categoryListView;
	SNVideoSearchView_iPhone *_videoSearchView;
	SNVideoItemView_iPhone *_queuedItemView;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	CGPoint _offsetPt;
	CGPoint _swipePt;
	
	float _scrollOffset;
	BOOL _isReloading;
	BOOL _isQueued;
}

-(id)initWithUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;

@end
