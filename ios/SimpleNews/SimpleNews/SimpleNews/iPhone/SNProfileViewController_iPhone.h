//
//  SNProfileViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"

@interface SNProfileViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
	UITableView *_tableView;
	NSMutableArray *_items;
	
	UILabel *_likesLabel;
	UILabel *_commentsLabel;
	UILabel *_sharesLabel;
}

@end
