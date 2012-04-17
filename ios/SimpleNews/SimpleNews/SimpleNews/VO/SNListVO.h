//
//  SNListVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNListVO : NSObject

+(SNListVO *)listWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int list_id;
@property (nonatomic) int totalInfluencers;
@property (nonatomic) int totalSubscribers;
@property (nonatomic, retain) NSMutableArray *curators;
@property (nonatomic, retain) NSString *curatorNames;
@property (nonatomic, retain) NSString *list_name;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *thumbURL;
@property (nonatomic, retain) NSString *list_info;

-(NSString *)subscribersFormatted;

@end
