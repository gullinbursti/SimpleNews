//
//  SNListVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNListVO.h"

@implementation SNListVO

@synthesize dictionary;
@synthesize list_id, totalInfluencers, list_name, list_info;

+(SNListVO *)listWithDictionary:(NSDictionary *)dictionary {
	SNListVO *vo = [[SNListVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.list_id = [[dictionary objectForKey:@"list_id"] intValue];
	vo.totalInfluencers = [[dictionary objectForKey:@"total"] intValue];
	vo.list_name = [dictionary objectForKey:@"name"];
	vo.list_info = [dictionary objectForKey:@"info"];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.list_name = nil;
	self.list_info = nil;
	
	[super dealloc];
}

@end
