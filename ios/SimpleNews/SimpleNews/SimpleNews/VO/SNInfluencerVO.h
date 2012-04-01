//
//  SNInfluencerVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNInfluencerVO : NSObject

+(SNInfluencerVO *)influencerWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int influencer_id;
@property (nonatomic) int totalArticles;
@property (nonatomic, retain) NSString *handle;
@property (nonatomic, retain) NSString *influencer_name;
@property (nonatomic, retain) NSString *avatar_url;
@property (nonatomic, retain) NSString *blurb;
@property (nonatomic, retain) NSArray *sources;

@end
