//
//  SNRootTopicViewCell.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBaseRootViewCell.h"
#import "SNTopicVO.h"

@interface SNRootTopicViewCell : SNBaseRootViewCell {
	UIButton *_followButton;
}

@property(nonatomic, retain) SNTopicVO *topicVO;

@end
