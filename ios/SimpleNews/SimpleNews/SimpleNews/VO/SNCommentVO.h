//
//  SNCommentVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCommentVO : NSObject

+(SNCommentVO *)commentWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int comment_id;
@property (nonatomic, retain) NSString *thumb_url;
@property (nonatomic, retain) NSString *twitterName;
@property (nonatomic, retain) NSString *twitterHandle;
@property (nonatomic, retain) NSString *comment_url;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSDate *added;

@end
