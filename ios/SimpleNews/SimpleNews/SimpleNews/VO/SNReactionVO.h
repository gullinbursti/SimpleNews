//
//  SNReactionVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNReactionVO : NSObject

+(SNReactionVO *)reactionWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int reaction_id;
@property (nonatomic, retain) NSString *thumb_url;
@property (nonatomic, retain) NSString *user_url;
@property (nonatomic, retain) NSString *reaction_url;
@property (nonatomic, retain) NSString *content;

@end
