//
//  SNFinalListCardView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBaseListCardView_iPhone.h"
#import "EGORefreshTableHeaderView.h"

@interface SNFinalListCardView_iPhone : SNBaseListCardView_iPhone <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate> {
	UITableView *_tableView;
	NSMutableArray *_lists;
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

-(id)initWithFrame:(CGRect)frame addlLists:(NSMutableArray *)lists;

@end
