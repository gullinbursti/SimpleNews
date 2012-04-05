//
//  SNListVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNListVO.h"

@implementation SNListVO

@synthesize dictionary;
@synthesize list_id, totalInfluencers, totalSubscribers, list_name, list_info, curator, imageURL, thumbURL;

+(SNListVO *)listWithDictionary:(NSDictionary *)dictionary {
	SNListVO *vo = [[SNListVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.list_id = [[dictionary objectForKey:@"list_id"] intValue];
	vo.totalInfluencers = [[dictionary objectForKey:@"influencers"] intValue];
	vo.totalSubscribers = [[dictionary objectForKey:@"subscribers"] intValue];
	vo.list_name = [dictionary objectForKey:@"name"];
	vo.curator = [dictionary objectForKey:@"curator"];
	vo.imageURL = [dictionary objectForKey:@"image_url"];
	vo.thumbURL = [dictionary objectForKey:@"thumb_url"];
	vo.list_info = [dictionary objectForKey:@"info"];
	
	return (vo);
}

-(NSString *)subscribersFormatted {
	NSNumber *subscribers = [NSNumber numberWithInt:self.totalSubscribers];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:kCFNumberFormatterDecimalStyle];
	[formatter setGroupingSeparator:@","];
	
	return ([formatter stringForObjectValue:subscribers]);
}

-(void)dealloc {
	self.dictionary = nil;
	self.list_name = nil;
	self.list_info = nil;
	self.curator = nil;
	self.imageURL = nil;
	self.thumbURL = nil;
	
	[super dealloc];
}

@end
