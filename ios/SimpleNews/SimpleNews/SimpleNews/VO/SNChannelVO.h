//
//  SNChannelVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNChannelVO : NSObject

+(SNChannelVO *)channelWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int channel_id;
@property (nonatomic, retain) NSString *youtube_id;
@property (nonatomic, retain) NSString *channel_title;
@property (nonatomic, retain) NSString *channel_info;
@property (nonatomic, retain) NSString *thumb_url;
@property (nonatomic, retain) NSString *image_url;


@end
