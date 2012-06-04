//
//  SNFriendProfileViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.25.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNTwitterUserVO.h"
#import "ASIFormDataRequest.h"

@interface SNFriendProfileViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
	SNTwitterUserVO *_vo;
	UILabel *_likesLabel;
	UILabel *_commentsLabel;
	UILabel *_sharesLabel;
	NSMutableArray *_items;
	UITableView *_tableView;
	ASIFormDataRequest *_notificationsRequest;
	
	NSMutableArray *_switches;
	UISwitch *_commentSwitch;
	UISwitch *_likeSwitch;
	UISwitch *_shareSwitch;
}

- (id)initWithTwitterUser:(SNTwitterUserVO *)vo;

@end
