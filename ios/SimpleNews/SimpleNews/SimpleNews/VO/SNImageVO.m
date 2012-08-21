//
//  SNImageVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.13.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNImageVO.h"

@implementation SNImageVO

@synthesize dictionary;
@synthesize imageID, articleID, typeID, ratio, url;

+(SNImageVO *)imageWithDictionary:(NSDictionary *)dictionary {
	SNImageVO *vo = [[SNImageVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.imageID = [[dictionary objectForKey:@"id"] intValue];
	vo.articleID = [[dictionary objectForKey:@"article_id"] intValue];
	vo.typeID = [[dictionary objectForKey:@"type_id"] intValue];
	vo.ratio = [[dictionary objectForKey:@"ratio"] floatValue];
	vo.url = [dictionary objectForKey:@"url"];
	
	return (vo);
}


-(void)dealloc {
	self.dictionary = nil;
	self.url = nil;
}

@end
