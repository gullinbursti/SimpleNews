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
@synthesize tag_id, title;

+(SNTagVO *)tagWithDictionary:(NSDictionary *)dictionary {
	
	SNTagVO *vo = [[SNTagVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.tag_id = [[dictionary objectForKey:@"tag_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	
	return (vo);
}

-(void)dealloc {
	dictionary = nil;
	title = nil;
}

@end
