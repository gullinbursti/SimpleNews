//
//  SNDeviceVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNDeviceVO.h"

@implementation SNDeviceVO

@synthesize dictionary;
@synthesize type_id, device_title;

+(SNDeviceVO *)deviceWithDictionary:(NSDictionary *)dictionary {
	SNDeviceVO *vo = [[SNDeviceVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.type_id = [[dictionary objectForKey:@"type_id"] intValue];
	vo.device_title = [dictionary objectForKey:@"title"];
	
	return (vo);
}

-(void)dealloc {
	dictionary = nil;
	device_title = nil;
}


@end
