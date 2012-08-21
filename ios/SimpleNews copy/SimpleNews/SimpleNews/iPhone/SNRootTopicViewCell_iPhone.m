//
//  SNRootTopicViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNRootTopicViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNRootTopicViewCell_iPhone

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
