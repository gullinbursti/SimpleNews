//
//  SNRootViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "SNTopicTimelineView_iPhone.h"
#import "SNDiscoveryListView_iPhone.h"
#import "MBLAsyncResource.h"

#import "ASIFormDataRequest.h"
#import "SNArticleVO.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNNavShareBtnView.h"
#import "SNNavLogoBtnView.h"

@class MBProgressHUD;

@interface SNRootViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, ASIHTTPRequestDelegate>
{
	MBLAsyncResource *_userResource;
	ASIHTTPRequest *_twitterRequest;
	
	SNTopicTimelineView_iPhone *_topicTimelineView;
	SNDiscoveryListView_iPhone *_discoveryListView;
	
	SNArticleVO *_articleVO;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	SNNavShareBtnView *_shareBtnView;
	SNNavLogoBtnView *_detailsBtnView;
	
	NSMutableArray *_topicsList;
	NSMutableArray *_topicCells;
	NSMutableArray *_profileItems;
	
	MBProgressHUD *_hud;
	UITableView *_topicsTableView;
	
	UIView *_holderView;
	UIImageView *_shadowImgView;
	UIButton *_profileButton;
	UILabel *_fullscreenTitleLabel;
	
	UIView *_blackMatteView;
	UIImageView *_fullscreenImgView;
	CGRect _fullscreenFrame;
	
	BOOL _reloading;
	BOOL _isIntro;
	
	int _swipeIndex;
	
	CGPoint _touchPt;
}


#define kTopicOffset 226.0f

@end
