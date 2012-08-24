//
//  SNRootViewController.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//#import "Facebook.h"

#import "SNTopicTimelineView.h"
#import "SNDiscoveryListViewController.h"
#import "MBLAsyncResource.h"

#import "ASIFormDataRequest.h"
#import "SNArticleVO.h"
#import "SNArticleVideoPlayerView.h"
#import "SNNavLogoBtnView.h"
#import "SNComposePopOverView.h"
#import "SNUserActivityView.h"

@class MBProgressHUD;

@interface SNRootViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, ASIHTTPRequestDelegate>
{
	MBLAsyncResource *_userResource;
	ASIHTTPRequest *_twitterRequest;
	
	
	ASIFormDataRequest *_shareRequest;
	ASIFormDataRequest *_likeRequest;
	
	
	SNTopicTimelineView *_topicTimelineView;
	SNDiscoveryListViewController *_discoveryListView;
	
	SNArticleVO *_articleVO;
	SNArticleVideoPlayerView *_videoPlayerView;
	SNNavLogoBtnView *_detailsBtnView;
	SNUserActivityView *_userActivityView;
	
	NSMutableArray *_topicsList;
	NSMutableArray *_profileItems;
	
	MBProgressHUD *_hud;
	UITableView *_topicsTableView;
	
	UIView *_holderView;
	UIImageView *_shadowImgView;
	UIButton *_profileButton;
	UIButton *_itunesButton;
	UIView *_fullscreenHeaderView;
	UIImageView *_fullscreenFooterImgView;
	
	UIView *_blackMatteView;
	UIImageView *_fullscreenImgView;
	CGRect _fullscreenFrame;
	UIButton *_likeButton;
	UIButton *_commentButton;
	
	BOOL _reloading;
	BOOL _isIntro;
	BOOL _isMainShare;
	BOOL _isMenuCovered;
	
	SNComposePopOverView *_composePopOverView;
	
	NSTimer *_popoverTimer;
	
	int _swipeIndex;
	
	CGPoint _touchPt;
}


#define kTopicOffset 226.0f

@end
