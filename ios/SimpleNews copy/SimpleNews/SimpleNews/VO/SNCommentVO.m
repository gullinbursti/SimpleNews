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
@synthesize comment_id, avatarURL, handle, content, isLiked, added;

+(SNCommentVO *)commentWithDictionary:(NSDictionary *)dictionary {
	SNCommentVO *vo = [[SNCommentVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.avatarURL = [dictionary objectForKey:@"avatar"];
	vo.handle = [dictionary objectForKey:@"handle"];
	vo.content = [dictionary objectForKey:@"content"];
	vo.isLiked = (BOOL)[[dictionary objectForKey:@"liked"] intValue];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.added = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.avatarURL = nil;
	self.handle = nil;
	self.content = nil;
}

@end
