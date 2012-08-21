//
//  SNRootTopicViewCell.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNRootTopicViewCell.h"
#import "SNAppDelegate.h"

@implementation SNRootTopicViewCell

@synthesize topicVO = _topicVO;

-(id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

#pragma mark - Accessors
- (void)setTopicVO:(SNTopicVO *)topicVO {
	NSLog(@"TOPIC :[%@]", topicVO.title);
	_topicVO = topicVO;
	_nameLabel.text = _topicVO.title;
}


@end
