//
//  SNListVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNListVO.h"
#import "SNCuratorVO.h"

@implementation SNListVO

@synthesize dictionary;
@synthesize list_id, totalInfluencers, totalSubscribers, isSubscribed, isApproved, totalLikes, list_name, list_info, curatorNames, curators, imageURL, thumbURL;

+(SNListVO *)listWithDictionary:(NSDictionary *)dictionary {
	SNListVO *vo = [[SNListVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.list_id = [[dictionary objectForKey:@"list_id"] intValue];
	vo.totalInfluencers = [[dictionary objectForKey:@"influencers"] intValue];
	vo.totalSubscribers = [[dictionary objectForKey:@"subscribers"] intValue];
	vo.totalLikes = [[dictionary objectForKey:@"likes"] intValue];
	vo.list_name = [dictionary objectForKey:@"name"];
	vo.imageURL = [dictionary objectForKey:@"image_url"];
	vo.thumbURL = [dictionary objectForKey:@"thumb_url"];
	vo.list_info = [dictionary objectForKey:@"info"];
	vo.isSubscribed = (BOOL)[[dictionary objectForKey:@"isSubscribed"] intValue];
	vo.isApproved = (BOOL)[[dictionary objectForKey:@"approved"] intValue];
	vo.curators = [NSMutableArray new];
	
	for (NSDictionary *curator in [dictionary objectForKey:@"curators"])
		[vo.curators addObject:[SNCuratorVO curatorWithDictionary:curator]];
	
	vo.curatorNames = @"by ";
	
	for (SNCuratorVO *curatorVO in vo.curators)
		vo.curatorNames = [vo.curatorNames stringByAppendingString:[NSString stringWithFormat:@"%@, ", curatorVO.curator_name]];
	
	vo.curatorNames = [vo.curatorNames substringToIndex:[vo.curatorNames length] - 2];
	
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
	self.curatorNames = nil;
	self.imageURL = nil;
	self.thumbURL = nil;
	self.curators = nil;
}

@end
