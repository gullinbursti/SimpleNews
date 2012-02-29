//
//  SNCategoryListView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SNVideoSearchView_iPhone.h"

@interface SNCategoryListView_iPhone : UIView <UIGestureRecognizerDelegate, UIScrollViewDelegate> {
	NSMutableArray *_allViews;
	NSMutableArray *_allItemVOs;
	NSMutableArray *_activeItemVOs;
	NSMutableArray *_pluginViews;
	NSMutableArray *_pluginVOs;
		
	UIScrollView *_scrollView;
	
	SNVideoSearchView_iPhone *_videoSearchView;
	
	BOOL _isSearching;
}

@end
