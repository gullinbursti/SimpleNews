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

#import "EGORefreshTableHeaderView.h"
#import "ASIFormDataRequest.h"

#import "FBConnect.h"

@interface SNFollowerGridViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	
	UIView *_holderView;
	
	BOOL _isReloading;
	UIScrollView *_scrollView;
	
	NSMutableArray *_itemViews;
	NSMutableArray *_followers;
	
	NSMutableArray *_tags;
	
	UIButton *_optionsButton;
	
	SNFollowerGridHeaderView_iPhone *_headerView;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	ASIFormDataRequest *_followersRequest;
	ASIFormDataRequest *_tagsRequest;
	
	BOOL _isDetails;
	BOOL _isOptions;
	BOOL _isArticles;
	BOOL _isSearching;
	BOOL _isFirst;
}


@end
