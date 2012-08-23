//
//  SNNetworkAppVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNetworkAppVO : NSObject

+(SNNetworkAppVO *)appWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int appID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) NSString *appStoreID;
@property (nonatomic, retain) NSString *icoURL;
@property (nonatomic, retain) NSDate *added;


@end
