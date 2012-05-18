//
//  SNRootViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNDiscoveryArticlesView_iPhone.h"
#import "SNArticleTimelineView_iPhone.h"
#import "MBLAsyncResource.h"

#import "ASIFormDataRequest.h"

@class MBProgressHUD;
@class SNDiscoveryArticlesView_iPhone;

@interface SNRootViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
	MBLAsyncResource *_userResource;
	MBLAsyncResource *_updateResource;
	MBLAsyncResource *_topicsResource;
	
	ASIHTTPRequest *_twitterRequest;

	SNDiscoveryArticlesView_iPhone *_discoveryArticlesView;
	SNArticleTimelineView_iPhone *_articleTimelineView;
	
	NSMutableArray *_topicsList;
	NSMutableArray *_popularLists;
	NSMutableArray *_subscribedCells;
	
	MBProgressHUD *_hud;
	UITableView *_topicsTableView;
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

@end
