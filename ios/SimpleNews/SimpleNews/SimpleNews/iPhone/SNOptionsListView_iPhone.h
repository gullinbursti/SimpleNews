//
//  SNOptionsListView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNOptionsListView_iPhone : UIView <UIGestureRecognizerDelegate, UIScrollViewDelegate> {
	NSMutableArray *_optionViews;
	NSMutableArray *_optionVOs;
	
	UIScrollView *_scrollView;
}


@end
