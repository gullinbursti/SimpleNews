//
//  SNFollowerGridViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SNFollowerGridHeaderView_iPhone.h"
#import "SNRecentFollowersView_iPhone.h"
#import "ASIFormDataRequest.h"

#import "FBConnect.h"

@interface SNFollowerGridViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate> {
	
	UIView *_holderView;
	
	UITableView *_tableView;
	UIScrollView *_scrollView;
	
	NSMutableArray *_itemViews;
	NSMutableArray *_categories;
	NSMutableArray *_categorizedFollowers;
	NSMutableArray *_followers;
	
	NSMutableArray *_tags;
	
	SNFollowerGridHeaderView_iPhone *_headerView;
	SNRecentFollowersView_iPhone *_recentFollowersView;
	
	ASIFormDataRequest *_followersRequest;
	ASIFormDataRequest *_tagsRequest;
	ASIFormDataRequest *_recentRequest;
	
	BOOL _isDetails;
	BOOL _isOptions;
	BOOL _isArticles;
	BOOL _isSearching;
	BOOL _isFirst;
}


@end
