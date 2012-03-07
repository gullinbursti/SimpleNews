//
//  SNVideoItemVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoItemVO.h"

@implementation SNVideoItemVO

@synthesize dictionary;
@synthesize video_id, type_id, youtube_id, video_title, video_info, channelImg_url, video_url, image_url, thumb_url, posted, postedDate;

+(SNVideoItemVO *)videoItemWithDictionary:(NSDictionary *)dictionary {
	
	SNVideoItemVO *vo = [[SNVideoItemVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.video_id = [[dictionary objectForKey:@"video_id"] intValue];
	vo.type_id = [[dictionary objectForKey:@"type_id"] intValue];
	vo.youtube_id = [dictionary objectForKey:@"youtube_id"];
	vo.video_title = [dictionary objectForKey:@"title"];
	vo.video_info = [dictionary objectForKey:@"info"];
	vo.video_url = [dictionary objectForKey:@"video"];
	vo.image_url = [dictionary objectForKey:@"image"];
	vo.thumb_url = [dictionary objectForKey:@"thumb"];
	vo.channelImg_url = [dictionary objectForKey:@"channel"];
	vo.postedDate = [dictionary objectForKey:@"date"];
	vo.posted = [dictionary objectForKey:@"date"];
	
	vo.thumb_url = [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/hqdefault.jpg", vo.youtube_id];
	vo.image_url = [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/hqdefault.jpg", vo.youtube_id];
	
	return (vo);
}

-(void)dealloc {
	dictionary = nil;
	youtube_id = nil;
	video_title = nil;
	video_url = nil;
	image_url = nil;
	thumb_url = nil;
}


//http://img.youtube.com/vi/pa14VNsdSYM/0.jpg
//http://i.ytimg.com/vi/%@/hqdefault.jpg

@end
