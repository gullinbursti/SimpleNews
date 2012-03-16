//
//  SNTagVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTagVO : NSObject

+(SNTagVO *)tagWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int tag_id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *blurb;
@property (nonatomic) int articleTotal;

@end
