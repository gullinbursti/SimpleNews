//
//  SNUserActivityView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNArticleVO.h"
#import "SNTabNavView.h"

@class MBProgressHUD;

@interface SNUserActivityView : UIView <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableArray *_articles;
	MBProgressHUD *_hud;
	SNTabNavView *_tabNavView;
}

@end
