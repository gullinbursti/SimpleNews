//
//  SNVideoItemVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNVideoItemVO : NSObject

+(SNVideoItemVO *)videoItemWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int video_id;
@property (nonatomic) int type_id;
@property (nonatomic, retain) NSString *youtube_id;
@property (nonatomic, retain) NSString *video_title;
@property (nonatomic, retain) NSString *video_info;
@property (nonatomic, retain) NSString *channelImg_url;
@property (nonatomic, retain) NSString *image_url;
@property (nonatomic, retain) NSString *thumb_url;
@property (nonatomic, retain) NSString *video_url;

@end
