//
//  SNImageVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.13.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNImageVO : NSObject

+(SNImageVO *)imageWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int imageID;
@property (nonatomic) int articleID;
@property (nonatomic) int typeID;
@property (nonatomic) float ratio;
@property (nonatomic, retain) NSString *url;


@end
