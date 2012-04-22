//
//  SNCuratorVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCuratorVO : NSObject

+(SNCuratorVO *)curatorWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int curator_id;
@property (nonatomic, retain) NSString *twitter_handle;
@property (nonatomic, retain) NSString *curator_name;
@property (nonatomic, retain) NSString *blurb;
@property (nonatomic) BOOL hasApproved;
@property (nonatomic) int totalLists;

@end
