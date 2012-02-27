//
//  SNDeviceVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDeviceVO : NSObject

+(SNDeviceVO *)deviceWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int type_id;
@property (nonatomic, retain) NSString *device_title;

@end
