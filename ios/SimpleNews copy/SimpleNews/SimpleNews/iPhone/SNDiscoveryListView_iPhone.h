//
//  SNDiscoveryListView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBLPageViewController.h"
#import "MBLAsyncResource.h"
#import "MBProgressHUD.h"
#import "SNPaginationView.h"
#import "SNNavListBtnView.h"

@interface SNDiscoveryListView_iPhone : MBLPageViewController <MBLPageViewControllerDelegate> {
	NSMutableArray *_articles;
	
	MBProgressHUD *_progressHUD;
	SNPaginationView *_paginationView;
	SNNavListBtnView *_listBtnView;
	//NSDate *_lastDate;
	BOOL _isTop10List;
}

@property (nonatomic, retain) UIView *overlayView;

- (id)initWithHeaderTitle:(NSString *)title isTop10:(BOOL)isPopular;

- (void)interactionEnabled:(BOOL)isEnabled;

@end
