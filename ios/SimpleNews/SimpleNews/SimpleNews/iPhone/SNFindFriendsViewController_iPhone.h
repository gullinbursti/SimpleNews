//
//  SNFindFriendsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"

@interface SNFindFriendsViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
	UITableView *_tableView;
	NSMutableArray *_friendIDs;
	NSMutableArray *_friends;
	NSArray *_sectionTitles;
	BOOL _isFinder;
	int _selectedIndex;
	
	ASIHTTPRequest *_idsRequest;
	ASIHTTPRequest *_followingBlockRequest;
	ASIFormDataRequest *_friendLookupRequest;
	ASIFormDataRequest *_myFriendsRequest;
	
	MBProgressHUD *_progressHUD;
}

-(id)initAsFinder;
-(id)initAsList;

@end
