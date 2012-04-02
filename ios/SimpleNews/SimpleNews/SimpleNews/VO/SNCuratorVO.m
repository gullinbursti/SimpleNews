//
//  SNCuratorVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCuratorVO.h"

@implementation SNCuratorVO

@synthesize dictionary;
@synthesize curator_id, fb_id, curator_name, totalLists;

+(SNCuratorVO *)curatorWithDictionary:(NSDictionary *)dictionary {
	SNCuratorVO *vo = [[SNCuratorVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.curator_id = [[dictionary objectForKey:@"curator_id"] intValue];
	vo.totalLists = [[dictionary objectForKey:@"total"] intValue];
	vo.curator_name = [dictionary objectForKey:@"name"];
	vo.fb_id = [dictionary objectForKey:@"fb_id"];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.curator_name = nil;
	self.fb_id = nil;
	
	[super dealloc];
}
@end
