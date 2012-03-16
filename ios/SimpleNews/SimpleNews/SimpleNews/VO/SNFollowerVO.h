//
//  SNFollowerVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNFollowerVO : NSObject

+(SNFollowerVO *)followerWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int follower_id;
@property (nonatomic) int totalArticles;
@property (nonatomic, retain) NSString *handle;
@property (nonatomic, retain) NSString *follower_name;
@property (nonatomic, retain) NSString *avatar_url;
@property (nonatomic, retain) NSString *blurb;

@end
