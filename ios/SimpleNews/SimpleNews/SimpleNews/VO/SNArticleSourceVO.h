//
//  SNArticleSourceVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNArticleSourceVO : NSObject

+(SNArticleSourceVO *)sourceWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *iconURL;

@end
