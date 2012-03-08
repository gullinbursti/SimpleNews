//
//  SNChannelGridViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SNOptionsListView_iPhone.h"
#import "SNVideoSearchView_iPhone.h"
#import "SNPlayingListViewController_iPhone.h"

#import "EGORefreshTableHeaderView.h"
#import "ASIFormDataRequest.h"

@interface SNChannelGridViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	
	UIView *_holderView;
	
	BOOL _isReloading;
	UIScrollView *_scrollView;
	
	NSMutableArray *_videoItems;
	NSMutableArray *_itemViews;
	
	NSMutableArray *_channels;
	
	SNVideoSearchView_iPhone *_videoSearchView;
	SNPlayingListViewController_iPhone *_playingListViewController;
	SNOptionsListView_iPhone *_optionsListView;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	ASIFormDataRequest *_channelsRequest;
	
	CGPoint _offsetPt;
	
	float _scrollOffset;
	
	int _playingIndex;
	
	BOOL _isDetails;
	BOOL _isOptions;
	BOOL _isSearching;
}

@end
