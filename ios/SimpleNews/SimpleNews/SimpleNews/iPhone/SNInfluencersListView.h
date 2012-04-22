//
//  SNInfluencersListView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "SNListVO.h"
#import "SNListInfoView_iPhone.h"

@interface SNInfluencersListView : UIView <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate> {
	NSMutableArray *_influencers;
	UITableView *_tableView;
	
	ASIFormDataRequest *_influencersRequest;
	
	SNListVO *_vo;
	SNListInfoView_iPhone *_listInfoView;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;

@end
