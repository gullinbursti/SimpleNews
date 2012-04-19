//
//  SNRootViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"

@interface SNRootViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
	ASIFormDataRequest *_userRequest;
	ASIFormDataRequest *_subscribedListsRequest;
	ASIFormDataRequest *_popularListsRequest;
	ASIHTTPRequest *_twitterRequest;
	
	NSMutableArray *_subscribedLists;
	NSMutableArray *_popularLists;
	
	UITableView *_subscribedTableView;
	UITableView *_popularTableView;
	UIButton *_articlesButton;
	
	UIImageView *_toggleLtImgView;
	UIImageView *_toggleRtImgView;
	
	BOOL _isFollowingList;
}

@end
