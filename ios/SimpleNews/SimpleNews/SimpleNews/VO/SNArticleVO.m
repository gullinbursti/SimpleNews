//
//  SNArticleVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleVO.h"

@implementation SNArticleVO

@synthesize dictionary;
@synthesize article_id, title, twitterName, tweetMessage, content, bgImage_url, avatarImage_url, isDark, added;

+(SNArticleVO *)articleWithDictionary:(NSDictionary *)dictionary {
	
	SNArticleVO *vo = [[SNArticleVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.article_id = [[dictionary objectForKey:@"article_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	vo.twitterName = [dictionary objectForKey:@"twitter_name"];
	vo.tweetMessage = [dictionary objectForKey:@"tweet_msg"]; 
	vo.content = [dictionary objectForKey:@"content"];
	vo.bgImage_url = [dictionary objectForKey:@"bg_url"];
	vo.avatarImage_url = [dictionary objectForKey:@"avatar_url"];
	vo.isDark = (BOOL)([[dictionary objectForKey:@"is_dark"] isEqualToString:@"Y"]);
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.added = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	[dateFormat release];
	
	return (vo);
}

-(void)dealloc {
	dictionary = nil;
	title = nil;
	content = nil;
	bgImage_url = nil;
	avatarImage_url = nil;
}

@end
