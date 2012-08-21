//
//  SNTopicVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTopicVO : NSObject

+(SNTopicVO *)topicWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int topic_id;
@property (nonatomic, retain) NSString *title;

@end
