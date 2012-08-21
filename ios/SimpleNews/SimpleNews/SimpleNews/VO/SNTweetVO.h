//
//  SNTweetVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTweetVO : NSObject

+(SNTweetVO *)tweetWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic, retain) NSString *tweet_id;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) NSString *content;


@end
