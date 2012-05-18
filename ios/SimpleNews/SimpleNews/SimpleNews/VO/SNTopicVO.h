//
//  SNTopicVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTopicVO : NSObject

+(SNTopicVO *)topicWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int topic_id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *hashtags;

@end
