//
//  SNInfluencerVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNInfluencerVO.h"

@implementation SNInfluencerVO

@synthesize dictionary;
@synthesize influencer_id, totalArticles, handle, influencer_name, avatar_url, blurb, sources;

+(SNInfluencerVO *)influencerWithDictionary:(NSDictionary *)dictionary {
	
	SNInfluencerVO *vo = [[SNInfluencerVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.influencer_id = [[dictionary objectForKey:@"influencer_id"] intValue];
	vo.handle = [dictionary objectForKey:@"handle"];
	vo.influencer_name = [dictionary objectForKey:@"name"];
	vo.avatar_url = [dictionary objectForKey:@"avatar_url"];
	vo.blurb = [dictionary objectForKey:@"blurb"];
	vo.totalArticles = [[dictionary objectForKey:@"article_total"] intValue];
	vo.sources = [dictionary objectForKey:@"source_types"];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.handle = nil;
	self.influencer_name = nil;
	self.avatar_url = nil;
	self.blurb = nil;
	self.sources = nil;
	
	[super dealloc];
}

@end
