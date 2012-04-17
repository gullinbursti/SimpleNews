//
//  SNCommentVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCommentVO.h"

@implementation SNCommentVO

@synthesize dictionary;
@synthesize comment_id, thumb_url, twitterName, twitterHandle, comment_url, content, added;

+(SNCommentVO *)commentWithDictionary:(NSDictionary *)dictionary {
	SNCommentVO *vo = [[SNCommentVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.thumb_url = [dictionary objectForKey:@"thumb_url"];
	vo.twitterName = [dictionary objectForKey:@"name"];
	vo.twitterHandle = [dictionary objectForKey:@"handle"];
	vo.comment_url = [dictionary objectForKey:@"comment_url"];
	vo.content = [dictionary objectForKey:@"content"];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.added = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	[dateFormat release];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.thumb_url = nil;
	self.twitterName = nil;
	self.twitterHandle = nil;
	self.comment_url = nil;
	self.content = nil;
	
	[super dealloc];
}

@end
