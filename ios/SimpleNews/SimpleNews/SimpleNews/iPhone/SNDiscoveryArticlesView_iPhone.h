//
//  SNDiscoveryArticlesView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>

#import "ASIFormDataRequest.h"
#import "SNListVO.h"
#import "EGORefreshTableHeaderView.h"
#import "EGOImageView.h"
#import "SNPaginationView.h"

@interface SNDiscoveryArticlesView_iPhone : UIView <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	ASIFormDataRequest *_updateRequest;
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
	
	UIScrollView *_scrollView;
	UIView *_overlayView;
	UIButton *_doneButton;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_timelineTweets;
	
	SNListVO *_vo;
	
	SNPaginationView *_paginationView;
	
	UIView *_blackMatteView;
	EGOImageView *_fullscreenImgView;
	CGRect _fullscreenFrame;
	NSDate *_lastDate;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;

@end
