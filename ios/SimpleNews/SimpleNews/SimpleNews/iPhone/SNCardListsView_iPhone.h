//
//  SNCardListsView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPaginationView.h"

@interface SNCardListsView_iPhone : UIView <UIScrollViewDelegate> {
	
	UIScrollView *_scrollView;
	
	UIButton *_rootListButton;
	NSArray *_lists;
	SNPaginationView *_paginationView;
	
	BOOL _isIntroed;
}

-(id)initWithLists:(NSArray *)unsortedLists;

@end
