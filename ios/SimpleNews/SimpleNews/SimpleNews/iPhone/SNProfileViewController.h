//
//  SNProfileViewController.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"

@interface SNProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate> {
	UITableView *_tableView;
	NSMutableArray *_items;
	NSArray *_switches;
	
	UILabel *_likesLabel;
	UILabel *_commentsLabel;
	UILabel *_sharesLabel;
	UISwitch *_switch;
}

@end
