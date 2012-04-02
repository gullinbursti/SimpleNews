//
//  SNRootViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"

@interface SNRootViewController_iPhone : UIViewController <ASIHTTPRequestDelegate> {
	ASIFormDataRequest *_listsRequest;
	NSMutableArray *_lists;
	
	UIScrollView *_scrollView;
}

@end
