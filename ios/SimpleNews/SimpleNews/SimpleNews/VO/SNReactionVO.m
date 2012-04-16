//
//  SNReactionVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNReactionVO.h"

@implementation SNReactionVO

@synthesize dictionary;
@synthesize reaction_id, thumb_url, twitterName, twitterHandle, reaction_url, content;

+(SNReactionVO *)reactionWithDictionary:(NSDictionary *)dictionary {
	SNReactionVO *vo = [[SNReactionVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.thumb_url = [dictionary objectForKey:@"thumb_url"];
	vo.twitterName = [dictionary objectForKey:@"name"];
	vo.twitterHandle = [dictionary objectForKey:@"handle"];
	vo.reaction_url = [dictionary objectForKey:@"reaction_url"];
	vo.content = [dictionary objectForKey:@"content"];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.thumb_url = nil;
	self.twitterName = nil;
	self.twitterHandle = nil;
	self.reaction_url = nil;
	self.content = nil;
	
	[super dealloc];
}

@end
