//
//  SNTweetVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTweetVO.h"

@implementation SNTweetVO

@synthesize dictionary;
@synthesize tweet_id, author, avatar, content;

+(SNTweetVO *)tweetWithDictionary:(NSDictionary *)dictionary {
	
	SNTweetVO *vo = [[[SNTweetVO alloc] init] autorelease];
	vo.dictionary = dictionary;
	
	vo.tweet_id = [dictionary objectForKey:@"tweet_id"];
	vo.author = [dictionary objectForKey:@"author"];
	vo.avatar = [dictionary objectForKey:@"avatar"];
	vo.content = [dictionary objectForKey:@"content"];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.tweet_id = nil;
	self.author = nil;
	self.content = nil;
	
	[super dealloc];
}

@end
