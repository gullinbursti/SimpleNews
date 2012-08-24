//
//  SNTopicTimelineView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.18.12.
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

@interface SNTopicTimelineView : UIView <UIScrollViewDelegate, UIAlertViewDelegate, EGORefreshTableHeaderDelegate> {
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
	
	BOOL _hasImage;
	BOOL _isProfile;
}

@property (nonatomic, retain)UIView *overlayView;

-(id)initWithTopicVO:(SNTopicVO *)vo;
-(id)initWithProfileType:(int)type;
- (id)initAsFeed;
- (id)initAsActivity;
- (id)initAsProfile;

- (void)interactionEnabled:(BOOL)isEnabled;

@end
