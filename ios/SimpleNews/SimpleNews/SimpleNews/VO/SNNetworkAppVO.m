//
//  SNNetworkAppVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNNetworkAppVO.h"

@implementation SNNetworkAppVO

@synthesize dictionary;
@synthesize appID, title, info, appStoreID, icoURL, added;

+ (SNNetworkAppVO *)appWithDictionary:(NSDictionary *)dictionary {
	SNNetworkAppVO *vo = [[SNNetworkAppVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.appID = [[dictionary objectForKey:@"app_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	vo.info = [dictionary objectForKey:@"info"];
	vo.appStoreID = [dictionary objectForKey:@"appstore_id"];
	vo.icoURL = [dictionary objectForKey:@"ico_url"];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.added = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.title = nil;
	self.info = nil;
	self.appStoreID = nil;
	self.icoURL = nil;
	self.added = nil;
}

@end
