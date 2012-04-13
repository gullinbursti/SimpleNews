//
//  SNSubscribedListsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"
#import "SNPaginationView_iPhone.h"

@interface SNSubscribedListsViewController_iPhone : UIViewController <ASIHTTPRequestDelegate, UIScrollViewDelegate> {
	NSMutableArray *_subscribedLists;
	ASIFormDataRequest *_listsRequest;
	ASIFormDataRequest *_userRequest;
	
	UIView *_holderView;
	UIScrollView *_scrollView;
	
	UIButton *_rootListButton;
	
	SNPaginationView_iPhone	*_paginationView;
}

@end
