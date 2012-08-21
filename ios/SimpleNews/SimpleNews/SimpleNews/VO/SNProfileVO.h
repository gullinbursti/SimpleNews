//
//  SNProfileVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNProfileVO : NSObject

+(SNProfileVO *)profileWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int profileID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *info;



@end
