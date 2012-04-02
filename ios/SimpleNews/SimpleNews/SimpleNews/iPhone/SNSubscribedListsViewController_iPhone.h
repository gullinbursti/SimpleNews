//
//  SNSubscribedListsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"

@interface SNSubscribedListsViewController_iPhone : UIViewController <ASIHTTPRequestDelegate> {
	NSMutableArray *_subscribedLists;
	ASIFormDataRequest *_listsRequest;
	
	UIView *_holderView;
	UIScrollView *_scrollView;
}

@end
