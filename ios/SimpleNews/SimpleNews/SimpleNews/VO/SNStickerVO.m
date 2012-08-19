//
//  SNStickerVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.18.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNStickerVO.h"

@implementation SNStickerVO

@synthesize dictionary;
@synthesize imageID, title, topicID, url;

+(SNStickerVO *)stickerWithDictionary:(NSDictionary *)dictionary {
	SNStickerVO *vo = [[SNStickerVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.imageID = [[dictionary objectForKey:@"id"] intValue];
	vo.topicID = [[dictionary objectForKey:@"topic_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	vo.url = [dictionary objectForKey:@"url"];
	
	return (vo);
}


-(void)dealloc {
	self.dictionary = nil;
	self.title = nil;
	self.url = nil;
}


@end
