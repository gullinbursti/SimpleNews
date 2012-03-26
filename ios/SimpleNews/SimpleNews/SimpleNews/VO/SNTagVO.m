//
//  SNTagVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTagVO.h"

@implementation SNTagVO

@synthesize dictionary;
@synthesize tag_id, title, blurb, articleTotal;

+(SNTagVO *)tagWithDictionary:(NSDictionary *)dictionary {
	
	SNTagVO *vo = [[[SNTagVO alloc] init] autorelease];
	vo.dictionary = dictionary;
	
	vo.tag_id = [[dictionary objectForKey:@"tag_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	vo.blurb = [dictionary objectForKey:@"info"];
	vo.articleTotal = [[dictionary objectForKey:@"article_total"] intValue];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.title = nil;
	self.blurb = nil;
	
	[super dealloc];
}

@end
