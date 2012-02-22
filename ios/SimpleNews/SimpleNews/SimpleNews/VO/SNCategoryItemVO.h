//
//  SNCategoryItemVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCategoryItemVO : NSObject

+(SNCategoryItemVO *)categoryItemWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int category_id;
@property (nonatomic, retain) NSString *category_title;
@property (nonatomic, retain) NSString *category_info;


@end
