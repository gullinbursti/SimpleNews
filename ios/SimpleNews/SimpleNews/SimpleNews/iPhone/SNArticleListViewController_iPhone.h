//
//  SNArticleListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"

@interface SNArticleListViewController_iPhone : UIViewController <UIScrollViewDelegate, ASIHTTPRequestDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	
	UIView *_overlayView;
	UIButton *_gridButton;
	
	UIScrollView *_scrollView;
	NSMutableArray *_cardViews;
}

@end
