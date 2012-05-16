//
//  SNRootViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "SNDiscoveryArticlesView_iPhone.h"
#import "SNArticleTimelineView_iPhone.h"

@interface SNRootViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate> {
	ASIFormDataRequest *_userRequest;
	ASIFormDataRequest *_subscribedListsRequest;
	ASIFormDataRequest *_popularListsRequest;
	ASIFormDataRequest *_updateRequest;
	
	ASIHTTPRequest *_twitterRequest;
	
	EGORefreshTableHeaderView *_subscribedHeaderView;
	EGORefreshTableHeaderView *_popularHeaderView;
	SNDiscoveryArticlesView_iPhone *_discoveryArticlesView;
	SNArticleTimelineView_iPhone *_articleTimelineView;
	
	NSMutableArray *_subscribedLists;
	NSMutableArray *_popularLists;
	NSMutableArray *_subscribedCells;
	
	UITableView *_subscribedTableView;
	UITableView *_popularTableView;
	
	UIView *_holderView;
	UIImageView *_shadowImgView;
	UIButton *_profileButton;
	UIButton *_cardListsButton;
	UIImageView *_toggleLtImgView;
	UIImageView *_toggleRtImgView;
	
	BOOL _isFollowingList;
	BOOL _reloading;
	BOOL _isIntro;
	int _swipeIndex;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
