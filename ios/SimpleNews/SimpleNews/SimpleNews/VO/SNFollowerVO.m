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
@synthesize follower_id, totalArticles, handle, follower_name, avatar_url;

+(SNFollowerVO *)followerWithDictionary:(NSDictionary *)dictionary {
	
	SNFollowerVO *vo = [[SNFollowerVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.follower_id = [[dictionary objectForKey:@"follower_id"] intValue];
	vo.handle = [dictionary objectForKey:@"handle"];
	vo.follower_name = [dictionary objectForKey:@"name"];
	vo.avatar_url = [dictionary objectForKey:@"avatar_url"];
	vo.totalArticles = [[dictionary objectForKey:@"article_total"] intValue];
	
	return (vo);
}

-(void)dealloc {
	dictionary = nil;
	handle = nil;
	follower_name = nil;
	avatar_url = nil;
}

@end
