//
//  SNArticleListView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ASIFormDataRequest.h"
#import "SNShareSheetView_iPhone.h"
#import "SNFlippedArticleView_iPhone.h"
#import "SNListVO.h"
#import "EGORefreshTableHeaderView.h"
#import "EGOImageView.h"


@interface SNArticleListView_iPhone : UIView <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate> {
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
	
	BOOL _isFlipped;
	SNListVO *_vo;
	
	SNShareSheetView_iPhone *_shareSheetView;
	SNFlippedArticleView_iPhone *_flippedView;
	
	UIView *_blackMatteView;
	EGOImageView *_fullscreenImgView;
	CGRect _fullscreenFrame;
	NSDate *_lastDate;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;

@end
