//
//  SNDiscoveryListView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBLAsyncResource.h"
#import "MBProgressHUD.h"
#import "SNPaginationView.h"
#import "SNNavListBtnView.h"

@interface SNDiscoveryListView_iPhone : UIView <UIScrollViewDelegate> {
	UIScrollView *_scrollView;
	NSMutableArray *_articles;
	NSMutableArray *_cardViews;
	
	MBProgressHUD *_progressHUD;
	SNPaginationView *_paginationView;
	SNNavListBtnView *_listBtnView;
	NSDate *_lastDate;
}

- (void)interactionEnabled:(BOOL)isEnabled;



@end
