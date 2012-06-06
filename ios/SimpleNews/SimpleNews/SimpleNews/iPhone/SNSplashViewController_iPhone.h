//
//  SNSplashViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBLAsyncResource.h"

@interface SNSplashViewController_iPhone : UIViewController {
	NSTimer *_frameTimer;
	NSTimer *_topicTimer;
	
	int _frameIndex;
	int _topicIndex;
	int _imgIndex;
	
	UIImageView *_logoImgView;
	NSMutableArray *_topicNames;
	NSMutableArray *_imageURLs;
	
	UILabel *_topicLabel;
}

- (void)restart;

@end
