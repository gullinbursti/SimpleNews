//
//  SNProfileVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileVO.h"

@implementation SNProfileVO

@synthesize dictionary;
@synthesize profileID, title, info;

+(SNProfileVO *)profileWithDictionary:(NSDictionary *)dictionary {
	SNProfileVO *vo = [[SNProfileVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.profileID = [[dictionary objectForKey:@"profile_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	vo.info = [dictionary objectForKey:@"info"]; 
	
	return (vo);
}


-(void)dealloc {
	self.dictionary = nil;
	self.title = nil;
	self.info = nil;
}
@end
