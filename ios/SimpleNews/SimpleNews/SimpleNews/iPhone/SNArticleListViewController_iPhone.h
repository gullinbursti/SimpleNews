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
#import "SNPaginationView_iPhone.h"
#import "SNLoaderView_iPhone.h"
#import "SNArticleVideoPlayerView_iPhone.h"

#import "Facebook.h"

@interface SNArticleListViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, ASIHTTPRequestDelegate, FBRequestDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	ASIFormDataRequest *_latestArticlesRequest;
	ASIFormDataRequest *_olderArticlesRequest;
	
	UIView *_overlayView;
	UIView *_cardHolderView;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_timelineTweets;
	
	int _cardIndex;
	BOOL _isLastCard;
	int _list_id;
	
	SNShareSheetView_iPhone *_shareSheetView;
	
	UIButton *_rootListButton;
	
	UIView *_blackMatteView;
	SNLoaderView_iPhone *_loaderView;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	SNPaginationView_iPhone	*_paginationView;
	
	NSTimer *_timer;
}

-(id)initAsMostRecent;
-(id)initWithInfluencers;
-(id)initWithList:(int)list_id;
-(id)initWithTag:(int)tag_id;
-(id)initWithTags:(NSString *)tags;

@end
