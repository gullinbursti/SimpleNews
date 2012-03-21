//
//  SNArticleListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "SNVideoPlayerView_iPhone.h"
#import "ASIFormDataRequest.h"
#import "SNShareSheetView_iPhone.h"
#import "SNPaginationView_iPhone.h"
#import "SNLoaderView_iPhone.h"

#import "Facebook.h"

@interface SNArticleListViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, ASIHTTPRequestDelegate, FBRequestDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	ASIFormDataRequest *_latestArticlesRequest;
	ASIFormDataRequest *_olderArticlesRequest;
	
	UIView *_overlayView;
	UIView *_cardHolderView;
	
	NSMutableArray *_cardViews;
	
	int _cardIndex;
	BOOL _isSwiping;
	
	SNShareSheetView_iPhone *_shareSheetView;
	
	UIButton *_greyGridButton;
	UIButton *_whiteGridButton;
	UIButton *_greyShareButton;
	UIButton *_whiteShareButton;
	
	UIView *_blackMatteView;
	UIView *_videoDimmerView;
	SNVideoPlayerView_iPhone *_videoPlayerView;
	
	SNPaginationView_iPhone	*_paginationView;
	SNLoaderView_iPhone *_loaderView;
}

-(id)initAsMostRecent;
-(id)initWithFollowers;
-(id)initWithTag:(int)tag_id;
-(id)initWithTags:(NSString *)tags;

@end
