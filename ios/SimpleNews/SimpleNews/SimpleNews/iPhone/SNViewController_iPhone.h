//
//  SNViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoPlayerView_iPhone.h"

@interface SNViewController_iPhone : UIViewController <UIScrollViewDelegate> {
	UIUserInterfaceIdiom _userInterfaceIdiom;
	
	UIScrollView *_deviceScrollView;
	
	NSMutableArray *_videoItems;
	NSMutableArray *_viewControllers;
	
	SNVideoPlayerView_iPhone *_iphoneVideoView;
}

-(id)initWithUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;

@end
