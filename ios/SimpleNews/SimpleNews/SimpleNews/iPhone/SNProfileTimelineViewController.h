//
//  SNProfileTimelineViewController.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.24.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBLAsyncResource.h"
#import "EGORefreshTableHeaderView.h"

@interface SNProfileTimelineViewController : UIViewController <UIScrollViewDelegate, EGORefreshTableHeaderDelegate> {
	int _userID;
	
	NSDate *_lastDate;
	UIScrollView *_scrollView;
	NSMutableArray *_articleViews;
	NSMutableArray *_articles;
	UIButton *_loadMoreButton;
	UIActivityIndicatorView *_activityIndicatorView;
	UILabel *_loaderLabel;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

- (id)initWithUserID:(int)userID;

@end
