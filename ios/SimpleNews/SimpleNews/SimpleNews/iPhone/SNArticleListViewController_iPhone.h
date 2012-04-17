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
#import "SNFlippedArticleView_iPhone.h"
#import "SNListVO.h"

@interface SNArticleListViewController_iPhone : UIViewController <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	
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
}

-(id)initWithListVO:(SNListVO *)vo;

@end
