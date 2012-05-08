//
//  SNProfileArticlesViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"

@interface SNProfileArticlesViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
	ASIFormDataRequest *_articlesRequest;
	
	NSMutableArray *_articles;
	UITableView *_tableView;
	NSString *_headerTitle;
}

-(id)initAsArticlesRead;
-(id)initAsArticlesLiked;

@end
