//
//  SNArticleVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleVO.h"
#import "SNCommentVO.h"
#import "SNImageVO.h"
#import "SNTwitterUserVO.h"

@implementation SNArticleVO

@synthesize dictionary;
@synthesize article_id, topicID, type_id, topicTitle, title, article_url, hasLiked, twitterName, twitterHandle, tweetID, tweetMessage, content, video_url, avatarImage_url, totalLikes, added, comments, images, userLikes;

+(SNArticleVO *)articleWithDictionary:(NSDictionary *)dictionary {
	
	SNArticleVO *vo = [[SNArticleVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.article_id = [[dictionary objectForKey:@"article_id"] intValue];
	vo.topicID = [[dictionary objectForKey:@"list_id"] intValue];
	vo.topicTitle = [dictionary objectForKey:@"topic_name"];
	vo.type_id = [[dictionary objectForKey:@"type_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	vo.tweetID = [dictionary objectForKey:@"tweet_id"];
	vo.article_url = [dictionary objectForKey:@"article_url"];
	vo.twitterName = [dictionary objectForKey:@"twitter_name"];
	vo.twitterHandle = [dictionary objectForKey:@"twitter_handle"];
	vo.tweetMessage = [dictionary objectForKey:@"tweet_msg"]; 
	vo.content = [dictionary objectForKey:@"content"];
	vo.video_url = [dictionary objectForKey:@"video_url"];
	vo.avatarImage_url = [dictionary objectForKey:@"avatar_url"];
	vo.hasLiked = (BOOL)[[dictionary objectForKey:@"liked"] intValue];
	//vo.totalLikes = [[dictionary objectForKey:@"likes"] intValue];
	
	if (vo.title == (id)[NSNull null]) 
		vo.title = @"Untitled";
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	//[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.added = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	NSMutableArray *unsortedComments = [NSMutableArray new];
	for (NSDictionary *comment in [dictionary objectForKey:@"comments"])
		[unsortedComments addObject:[SNCommentVO commentWithDictionary:comment]];
	
	vo.comments = [NSMutableArray arrayWithArray:[unsortedComments sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]];
	
	vo.images = [NSMutableArray new];
	for (NSDictionary *image in [dictionary objectForKey:@"images"])
		[vo.images addObject:[SNImageVO imageWithDictionary:image]];
	
	vo.userLikes = [NSMutableArray new];
	for (NSDictionary *user in [dictionary objectForKey:@"likes"])
		[vo.userLikes addObject:[SNTwitterUserVO twitterUserWithDictionary:user]];
	
	vo.totalLikes = [vo.userLikes count];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.title = nil;
	self.twitterName = nil;
	self.twitterHandle = nil;
	self.tweetMessage = nil;
	self.content = nil;
	self.avatarImage_url = nil;
	self.video_url = nil;
	self.added = nil;
	self.comments = nil;
	self.images = nil;
}

@end
