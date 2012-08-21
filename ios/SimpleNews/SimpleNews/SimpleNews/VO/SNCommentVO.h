//
//  SNCommentVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCommentVO : NSObject

+(SNCommentVO *)commentWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int comment_id;
@property (nonatomic) BOOL isLiked;
@property (nonatomic, retain) NSString *avatarURL;
@property (nonatomic, retain) NSString *handle;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSDate *added;

@end
