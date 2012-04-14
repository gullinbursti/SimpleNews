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
#import "SNShareSheetView_iPhone.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNListVO.h"

@interface SNArticleListViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	ASIFormDataRequest *_latestArticlesRequest;
	ASIFormDataRequest *_olderArticlesRequest;
	
	UIScrollView *_scrollView;
	UIView *_overlayView;
	UIView *_cardHolderView;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_timelineTweets;
	
	int _cardIndex;
	BOOL _isLastCard;
	SNListVO *_vo;
	
	SNShareSheetView_iPhone *_shareSheetView;
	
	UIView *_blackMatteView;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
}

-(id)initWithListVO:(SNListVO *)vo;

@end
