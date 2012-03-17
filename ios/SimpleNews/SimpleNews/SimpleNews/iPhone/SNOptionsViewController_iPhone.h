//
//  SNOptionsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNOptionsViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate> {
	
	NSMutableArray *_optionViews;
	NSMutableArray *_optionVOs;
	
	UIScrollView *_scrollView;
}

@end
