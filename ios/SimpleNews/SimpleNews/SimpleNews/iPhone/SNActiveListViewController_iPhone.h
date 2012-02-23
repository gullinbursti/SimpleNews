//
//  SNActiveListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SNActiveListViewController_iPhone : UIViewController <UIGestureRecognizerDelegate> {
	NSMutableArray *_items;
	
	UIView *_progressBar;
}

@end
