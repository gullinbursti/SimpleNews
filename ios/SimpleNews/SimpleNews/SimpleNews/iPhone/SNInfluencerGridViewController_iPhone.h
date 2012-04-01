//
//  SNInfluencerGridViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SNInfluencerGridHeaderView_iPhone.h"
#import "SNRecentInfluencersView_iPhone.h"
#import "ASIFormDataRequest.h"

#import "FBConnect.h"

@interface SNInfluencerGridViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate> {
	
	UIView *_holderView;
	
	UITableView *_tableView;
	UIScrollView *_scrollView;
	
	NSMutableArray *_itemViews;
	NSMutableArray *_categories;
	NSMutableArray *_categorizedInfluencers;
	NSMutableArray *_influencers;
	
	NSMutableArray *_tags;
	
	SNInfluencerGridHeaderView_iPhone *_headerView;
	SNRecentInfluencersView_iPhone *_recentInfluencersView;
	
	ASIFormDataRequest *_influencersRequest;
	ASIFormDataRequest *_tagsRequest;
	ASIFormDataRequest *_recentRequest;
	
	BOOL _isDetails;
	BOOL _isOptions;
	BOOL _isArticles;
	BOOL _isSearching;
	BOOL _isFirst;
}


@end
