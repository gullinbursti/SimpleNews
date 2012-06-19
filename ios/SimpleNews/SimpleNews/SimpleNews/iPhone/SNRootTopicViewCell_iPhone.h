//
//  SNRootTopicViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBaseRootViewCell_iPhone.h"
#import "SNTopicVO.h"

@interface SNRootTopicViewCell_iPhone : SNBaseRootViewCell_iPhone {
	UIButton *_followButton;
}

@property(nonatomic, retain) SNTopicVO *topicVO;

@end
