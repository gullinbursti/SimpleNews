//
//  SNBaseTimelineViewController.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 09.03.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@interface SNBaseTimelineViewController : UIViewController <UIScrollViewDelegate, EGORefreshTableHeaderDelegate> {
	int _userID;
	
	NSDate *_lastDate;
	UIScrollView *_scrollView;
	NSMutableArray *_articleViews;
	NSMutableArray *_articles;
	UIButton *_loadMoreButton;
	UIActivityIndicatorView *_activityIndicatorView;
	UILabel *_loaderLabel;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	MBProgressHUD *_progressHUD;
	BOOL _reloading;
}

@end
