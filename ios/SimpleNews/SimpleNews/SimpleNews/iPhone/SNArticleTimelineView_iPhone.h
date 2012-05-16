//
//  SNArticleTimelineView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ASIFormDataRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "EGOImageView.h"
#import "MBProgressHUD.h"

#import "SNListVO.h"
#import "SNArticleVideoPlayerView_iPhone.h"

@interface SNArticleTimelineView_iPhone : UIView <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate, EGOImageViewDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	ASIFormDataRequest *_updateRequest;
	EGORefreshTableHeaderView *_refreshHeaderView;
	MBProgressHUD *_progressHUD;
	
	UIButton *_subscribeBtn;
	BOOL _reloading;
	
	UIScrollView *_scrollView;
	UIView *_overlayView;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_timelineTweets;
	
	SNListVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	
	UIView *_blackMatteView;
	EGOImageView *_fullscreenImgView;
	CGRect _fullscreenFrame;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;


@end
