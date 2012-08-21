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
@property (nonatomic) int topicID;
@property (nonatomic) int type_id;
@property (nonatomic) int totalLikes;
@property (nonatomic) BOOL hasLiked;
@property (nonatomic, retain) NSString *topicTitle;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *tweetID;
@property (nonatomic, retain) NSString *twitterName;
@property (nonatomic, retain) NSString *twitterHandle;
@property (nonatomic, retain) NSString *tweetMessage;
@property (nonatomic, retain) NSString *article_url;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *video_url;
@property (nonatomic, retain) NSString *avatarImage_url;
@property (nonatomic, retain) NSDate *added;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *userLikes;

@end
