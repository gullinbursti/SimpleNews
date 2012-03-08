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

@interface SNPlayingListViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, UIScrollViewDelegate> {
	
	UIScrollView *_scrollView;
	NSMutableArray *_videoItems;
	NSMutableArray *_views;
	
	int _index;
	
	UIButton *_gridButton;
	UIButton *_playButton;
	UIButton *_pauseButton;
	
	UIView *_overlayHolderView;
	
	SNVideoPlayerViewController_iPhone *_videoPlayerViewController;
	SNPaginationView *_paginationView;
	ASIFormDataRequest *_videosRequest;
	
	float _lastOffset;
}

-(id)initWithVideos:(NSMutableArray *)videos;
-(void)changeChannelVO:(SNChannelVO *)vo;

@end
