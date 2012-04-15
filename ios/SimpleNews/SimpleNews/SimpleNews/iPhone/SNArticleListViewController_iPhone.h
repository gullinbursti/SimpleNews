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
#import "SNListVO.h"

@interface SNArticleListViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	
	UIScrollView *_scrollView;
	UIView *_overlayView;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_timelineTweets;
	
	BOOL _isLastCard;
	SNListVO *_vo;
	
	SNShareSheetView_iPhone *_shareSheetView;
	
	UIView *_blackMatteView;
}

-(id)initWithListVO:(SNListVO *)vo;

@end
