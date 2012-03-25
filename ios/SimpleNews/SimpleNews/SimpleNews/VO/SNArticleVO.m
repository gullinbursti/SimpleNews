//
//  SNArticleVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleVO.h"
#import "SNTagVO.h"

@implementation SNArticleVO

@synthesize dictionary;
@synthesize article_id, type_id, title, article_url, short_url, twitterName, tweet_id, tweetMessage, content, bgImage_url, video_url, avatarImage_url, isDark, added, tags;

+(SNArticleVO *)articleWithDictionary:(NSDictionary *)dictionary {
	
	SNArticleVO *vo = [[SNArticleVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.article_id = [[dictionary objectForKey:@"article_id"] intValue];
	vo.type_id = [[dictionary objectForKey:@"type_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	vo.tweet_id = [dictionary objectForKey:@"tweet_id"];
	vo.article_url = [dictionary objectForKey:@"article_url"];
	vo.short_url = [dictionary objectForKey:@"short_url"];
	vo.twitterName = [dictionary objectForKey:@"twitter_name"];
	vo.tweetMessage = [dictionary objectForKey:@"tweet_msg"]; 
	vo.content = [dictionary objectForKey:@"content"];
	vo.bgImage_url = [dictionary objectForKey:@"bg_url"];
	vo.video_url = [dictionary objectForKey:@"video_url"];
	vo.avatarImage_url = [dictionary objectForKey:@"avatar_url"];
	vo.isDark = (BOOL)([[dictionary objectForKey:@"is_dark"] isEqualToString:@"Y"]);
	vo.tags = [NSMutableArray new];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.added = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	[dateFormat release];
	
	for (NSDictionary *tag in [dictionary objectForKey:@"tags"])
		[vo.tags addObject:[SNTagVO tagWithDictionary:tag]];
	
	
	return (vo);
}

-(void)dealloc {
	dictionary = nil;
	title = nil;
	tweet_id = nil;
	twitterName = nil;
	tweetMessage = nil;
	content = nil;
	bgImage_url = nil;
	avatarImage_url = nil;
	video_url = nil;
	added = nil;
	tags = nil;
	
	[super dealloc];
}

@end
