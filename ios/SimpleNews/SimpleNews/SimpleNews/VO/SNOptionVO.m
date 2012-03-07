//
//  SNOptionVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNOptionVO.h"

@implementation SNOptionVO

@synthesize dictionary;
@synthesize option_id, option_title;

+(SNOptionVO *)optionWithDictionary:(NSDictionary *)dictionary {
	SNOptionVO *vo = [[SNOptionVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.option_id = [[dictionary objectForKey:@"option_id"] intValue];
	vo.option_title = [dictionary objectForKey:@"title"];
	
	return (vo);
}


-(void)dealloc {
	self.dictionary = nil;
	self.option_title = nil;
	
	[super dealloc];
}
@end
