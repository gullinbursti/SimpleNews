//
//  SNArticleSourcesViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNListVO.h"

@interface SNArticleSourcesViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *_tableView;
	NSMutableArray *_sources;
	
	SNListVO *_vo;
}

-(id)initWithListVO:(SNListVO *)vo;

@end
