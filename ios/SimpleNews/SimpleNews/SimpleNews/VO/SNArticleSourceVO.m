//
//  SNArticleSourceVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleSourceVO.h"

@implementation SNArticleSourceVO

@synthesize dictionary;
@synthesize title, iconURL;


+(SNArticleSourceVO *)sourceWithDictionary:(NSDictionary *)dictionary {
	
	SNArticleSourceVO *vo = [[SNArticleSourceVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.title = [dictionary objectForKey:@"title"];
	vo.iconURL = [dictionary objectForKey:@"icon"];

	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.title = nil;
	self.iconURL = nil;
}

@end
