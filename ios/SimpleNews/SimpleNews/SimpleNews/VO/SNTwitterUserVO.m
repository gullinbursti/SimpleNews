//
//  SNTwitterUserVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNTwitterUserVO.h"

@implementation SNTwitterUserVO

@synthesize dictionary;
@synthesize userID, twitterID, handle, avatarURL, name;

+(SNTwitterUserVO *)twitterUserWithDictionary:(NSDictionary *)dictionary {
	SNTwitterUserVO *vo = [[SNTwitterUserVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.twitterID = [dictionary objectForKey:@"id_str"];
	vo.name = [dictionary objectForKey:@"name"];
	vo.handle = [dictionary objectForKey:@"screen_name"];
	vo.avatarURL = [dictionary objectForKey:@"profile_image_url"];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.twitterID = nil;
	self.name = nil;
	self.handle = nil;
	self.avatarURL = nil;
}
@end
