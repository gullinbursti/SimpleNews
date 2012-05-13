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
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNListVO.h"
#import "EGOImageView.h"
#import "SNPaginationView.h"

@interface SNDiscoveryArticlesView_iPhone : UIView <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate, EGOImageViewDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	
	UIScrollView *_scrollView;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_timelineTweets;
	
	SNListVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	SNPaginationView *_paginationView;
	
	UIView *_blackMatteView;
	EGOImageView *_fullscreenImgView;
	CGRect _fullscreenFrame;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;

@end
