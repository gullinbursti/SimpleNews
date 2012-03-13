//
//  SNPlayingListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideoPlayerViewController_iPhone.h"
#import "SNPaginationView.h"
#import "ASIFormDataRequest.h"
#import "SNChannelVO.h"
#import "SNVideoItemVO.h"
#import "SNYouTubeScraper.h"

@interface SNPlayingListViewController_iPhone : UIViewController <SNYouTubeScraperDelegate, ASIHTTPRequestDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIWebViewDelegate> {
	
	UIScrollView *_scrollView;
	NSMutableArray *_videoItems;
	NSMutableArray *_views;
	
	int _index;
	
	UIButton *_channelsButton;
	UIButton *_shareButton;
	UIImageView *_playImgView;
	UIImageView *_pauseImgView;
	
	UIView *_overlayHolderView;
	
	SNVideoPlayerViewController_iPhone *_videoPlayerViewController;
	UIView *_videoLoadOverlayView;
	
	
	SNPaginationView *_paginationView;
	ASIFormDataRequest *_videosRequest;
	
	SNVideoItemVO *_videoItemVO;
	SNYouTubeScraper *_youTubeScraper;
	
	NSMutableDictionary *_ytVideos;
	BOOL _isFirstVideo;
	UIWebView *_webView;
	
	float _lastOffset;
}

-(id)initWithVO:(SNChannelVO *)vo;
-(void)changeChannelVO:(SNChannelVO *)vo;

@end
