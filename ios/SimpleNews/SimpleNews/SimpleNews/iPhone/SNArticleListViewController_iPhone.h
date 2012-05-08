//
//  SNArticleListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ASIFormDataRequest.h"
#import "SNListVO.h"
#import "EGORefreshTableHeaderView.h"
#import "EGOImageView.h"

@interface SNArticleListViewController_iPhone : UIViewController <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	ASIFormDataRequest *_updateRequest;
	EGORefreshTableHeaderView *_refreshHeaderView;
	UIButton *_subscribeBtn;
	BOOL _reloading;
	
	UIScrollView *_scrollView;
	UIView *_overlayView;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_timelineTweets;
	
	SNListVO *_vo;
	
	UIView *_blackMatteView;
	EGOImageView *_fullscreenImgView;
	CGRect _fullscreenFrame;
	NSDate *_lastDate;
}

-(id)initWithListVO:(SNListVO *)vo;

@end
