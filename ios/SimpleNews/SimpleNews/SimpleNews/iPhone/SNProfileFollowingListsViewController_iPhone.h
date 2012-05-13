//
//  SNProfileFollowingListsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

@interface SNProfileFollowingListsViewController_iPhone : UIViewController<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
	ASIFormDataRequest *_listsRequest;
	MBProgressHUD *_progressHUD;
	
	NSMutableArray *_lists;
	UITableView *_tableView;
}

@end
