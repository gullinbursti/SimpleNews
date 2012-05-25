//
//  SNTwitterFriendArticlesViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "SNTwitterUserVO.h"

@interface SNTwitterFriendArticlesViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
	ASIFormDataRequest *_articlesRequest;
	MBProgressHUD *_progressHUD;
	
	NSMutableArray *_articles;
	UITableView *_tableView;
	NSString *_headerTitle;
	SNTwitterUserVO *_vo;
}

-(id)initAsArticlesRead:(SNTwitterUserVO *)vo;
-(id)initAsArticlesLiked:(SNTwitterUserVO *)vo;

@end
