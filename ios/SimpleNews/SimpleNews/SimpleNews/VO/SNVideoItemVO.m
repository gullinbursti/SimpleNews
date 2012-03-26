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
	
	SNVideoItemVO *vo = [[[SNVideoItemVO alloc] init] autorelease];
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
	
	//NSString *tmp = [dictionary objectForKey:@"date"];
	//tmp = [vo.posted substringToIndex:[vo.posted length] - 5];
	//tmp = [tmp stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	
	//NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	//[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	//vo.postedDate = [dateFormat dateFromString:@"2012-03-08 10:23:00"];
	//[dateFormat release];
	
	//NSLog(@"VO:[%@]", [dateFormat dateFromString:[dictionary objectForKey:@"date"]]);
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.youtube_id = nil;
	self.video_title = nil;
	self.video_info = nil;
	self.video_url = nil;
	self.image_url = nil;
	self.thumb_url = nil;
	self.channelImg_url = nil;
	self.postedDate = nil;
	self.posted = nil;
	
	[super dealloc];
}


//http://img.youtube.com/vi/pa14VNsdSYM/0.jpg
//http://i.ytimg.com/vi/%@/hqdefault.jpg

@end
