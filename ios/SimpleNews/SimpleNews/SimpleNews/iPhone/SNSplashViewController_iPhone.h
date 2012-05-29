//
//  SNSplashViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"

@interface SNSplashViewController_iPhone : UIViewController <ASIHTTPRequestDelegate> {
	NSTimer *_frameTimer;
	NSTimer *_topicTimer;
	
	int _frameIndex;
	int _topicIndex;
	UIImageView *_logoImgView;
	NSMutableArray *_topics;
	
	UILabel *_topicLabel;
}

@end
