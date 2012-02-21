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
@synthesize video_id, type_id, video_title, video_url, image_url;

+(SNVideoItemVO *)videoItemWithDictionary:(NSDictionary *)dictionary {
	
	SNVideoItemVO *videoItemVO = [[SNVideoItemVO alloc] init];
	videoItemVO.dictionary = dictionary;
	
	videoItemVO.video_id = [[dictionary objectForKey:@"video_id"] intValue];
	videoItemVO.type_id = [[dictionary objectForKey:@"type_id"] intValue];
	videoItemVO.video_title = [dictionary objectForKey:@"title"];
	videoItemVO.video_url = [dictionary objectForKey:@"video"];
	videoItemVO.image_url = [dictionary objectForKey:@"image"];
	
	return (videoItemVO);
}

-(void)dealloc {
	dictionary = nil;
	video_title = nil;
	video_url = nil;
	image_url = nil;
}

@end
