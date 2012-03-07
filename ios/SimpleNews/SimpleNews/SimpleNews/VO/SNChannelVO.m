//
//  SNChannelVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNChannelVO.h"

@implementation SNChannelVO

@synthesize dictionary;
@synthesize channel_id, youtube_id, channel_title, channel_info, image_url, thumb_url;

+(SNChannelVO *)channelWithDictionary:(NSDictionary *)dictionary {
	
	SNChannelVO *vo = [[SNChannelVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.channel_id = [[dictionary objectForKey:@"channel_id"] intValue];
	vo.youtube_id = [dictionary objectForKey:@"youtube_id"];
	vo.channel_title = [dictionary objectForKey:@"title"];
	vo.channel_info = [dictionary objectForKey:@"info"];
	vo.image_url = [dictionary objectForKey:@"image"];
	vo.thumb_url = [dictionary objectForKey:@"thumb"];
	
	return (vo);
}

-(void)dealloc {
	dictionary = nil;
	youtube_id = nil;
	channel_title = nil;
	channel_info = nil;
	image_url = nil;
	thumb_url = nil;
}


@end
