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
#import "MBLAsyncResource.h"
#import "SNTabNavView.h"

#import "SNTopicVO.h"
#import "SNArticleVO.h"

#import "SNNavListBtnView.h"

@interface SNBaseTimelineViewController : UIViewController <UIScrollViewDelegate, EGORefreshTableHeaderDelegate> {
	NSMutableArray *_articles;
	EGORefreshTableHeaderView *_refreshHeaderView;
	MBProgressHUD *_progressHUD;
	
	BOOL _reloading;
	
	UIScrollView *_scrollView;
	UIButton *_fullscreenShareButton;
	UIActivityIndicatorView *_activityIndicatorView;
	UILabel *_loaderLabel;
	UIButton *_loadMoreButton;
	
	NSMutableArray *_articleViews;
	
	SNArticleVO *_articleVO;
	SNTopicVO *_vo;
	
	SNNavListBtnView *_listBtnView;
	SNTabNavView *_tabNavView;
	
	NSDate *_lastDate;
	int _lastID;
	int _timelineType;
	NSString *_timelineTitle;
	
	BOOL _hasImage;
	BOOL _isProfile;
}

@property (nonatomic, retain)UIView *overlayView;

- (id)initAsFeed;
- (id)initAsPopular;
- (id)initAsActivity;
- (id)initAsProfile;

- (void)interactionEnabled:(BOOL)isEnabled;

@end
