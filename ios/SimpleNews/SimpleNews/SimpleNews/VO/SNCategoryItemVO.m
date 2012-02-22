//
//  SNCategoryItemVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCategoryItemVO.h"

@implementation SNCategoryItemVO

@synthesize dictionary;
@synthesize category_id, category_title, category_info;

+(SNCategoryItemVO *)categoryItemWithDictionary:(NSDictionary *)dictionary {
	SNCategoryItemVO *vo = [[SNCategoryItemVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.category_id = [[dictionary objectForKey:@"category_id"] intValue];
	vo.category_title = [dictionary objectForKey:@"title"];
	vo.category_info = [dictionary objectForKey:@"info"];
	
	return (vo);
}

-(void)dealloc {
	dictionary = nil;
	category_title = nil;
	category_info = nil;
}

@end
