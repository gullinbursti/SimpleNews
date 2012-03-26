//
//  SNFollowerVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFollowerVO.h"

@implementation SNFollowerVO

@synthesize dictionary;
@synthesize follower_id, totalArticles, handle, follower_name, avatar_url, blurb;

+(SNFollowerVO *)followerWithDictionary:(NSDictionary *)dictionary {
	
	SNFollowerVO *vo = [[SNFollowerVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.follower_id = [[dictionary objectForKey:@"follower_id"] intValue];
	vo.handle = [dictionary objectForKey:@"handle"];
	vo.follower_name = [dictionary objectForKey:@"name"];
	vo.avatar_url = [dictionary objectForKey:@"avatar_url"];
	vo.blurb = [dictionary objectForKey:@"blurb"];
	vo.totalArticles = [[dictionary objectForKey:@"article_total"] intValue];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.handle = nil;
	self.follower_name = nil;
	self.avatar_url = nil;
	self.blurb = nil;
	
	[super dealloc];
}

@end
