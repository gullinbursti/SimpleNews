//
//  SNFollowerGridViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SNOptionsListView_iPhone.h"
#import "SNFollowerGridHeaderView_iPhone.h"

#import "EGORefreshTableHeaderView.h"
#import "ASIFormDataRequest.h"

@interface SNFollowerGridViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	
	UIView *_holderView;
	
	BOOL _isReloading;
	UIScrollView *_scrollView;
	
	NSMutableArray *_itemViews;
	NSMutableArray *_followers;
	
	SNFollowerGridHeaderView_iPhone *_headerView;
	SNOptionsListView_iPhone *_optionsListView;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	ASIFormDataRequest *_followersRequest;
	
	BOOL _isDetails;
	BOOL _isOptions;
	BOOL _isArticles;
	BOOL _isSearching;
	
	int _totSelected;
	NSString *_selectedFollowers;
	NSMutableArray *_selectedVOs;
}


@end
