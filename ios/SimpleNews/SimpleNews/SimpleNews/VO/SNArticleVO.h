//
//  SNArticleVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNArticleVO : NSObject

+(SNArticleVO *)articleWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int article_id;
@property (nonatomic) int type_id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *tweet_id;
@property (nonatomic, retain) NSString *twitterName;
@property (nonatomic, retain) NSString *twitterHandle;
@property (nonatomic, retain) NSString *tweetMessage;
@property (nonatomic, retain) NSString *article_url;
@property (nonatomic, retain) NSString *short_url;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *bgImage_url;
@property (nonatomic, retain) NSString *thumb_url;
@property (nonatomic, retain) NSString *video_url;
@property (nonatomic, retain) NSString *avatarImage_url;
@property (nonatomic, retain) NSDate *added;
@property (nonatomic, retain) NSMutableArray *tags;
@property (nonatomic, retain) NSMutableArray *reactions;
@property (nonatomic) BOOL isDark;

@end
