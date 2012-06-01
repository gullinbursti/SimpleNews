//
//  SNTopicVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTopicVO.h"
#import "SNCommentVO.h"

@implementation SNTopicVO

@synthesize dictionary;
@synthesize topic_id, title;

+ (SNTopicVO *)topicWithDictionary:(NSDictionary *)dictionary {
	SNTopicVO *vo = [[SNTopicVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.topic_id = [[dictionary objectForKey:@"topic_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.title = nil;
}

@end
