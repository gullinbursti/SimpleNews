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

@interface SNRootViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate> {
	ASIFormDataRequest *_userRequest;
	ASIFormDataRequest *_subscribedListsRequest;
	ASIFormDataRequest *_popularListsRequest;
	ASIHTTPRequest *_twitterRequest;
	
	EGORefreshTableHeaderView *_subscribedHeaderView;
	EGORefreshTableHeaderView *_popularHeaderView;
	
	
	NSMutableArray *_subscribedLists;
	NSMutableArray *_popularLists;
	
	UITableView *_subscribedTableView;
	UITableView *_popularTableView;
	
	UIImageView *_toggleLtImgView;
	UIImageView *_toggleRtImgView;
	
	BOOL _isFollowingList;
	BOOL _reloading;
	BOOL _isIntro;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
