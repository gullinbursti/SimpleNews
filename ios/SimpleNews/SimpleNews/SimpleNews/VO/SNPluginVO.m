//
//  SNPluginVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNPluginVO.h"

@implementation SNPluginVO

@synthesize dictionary;
@synthesize plugin_id, plugin_title, plugin_info, cost;

+(SNPluginVO *)pluginWithDictionary:(NSDictionary *)dictionary {
	SNPluginVO *vo = [[SNPluginVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.plugin_id = [[dictionary objectForKey:@"plugin_id"] intValue];
	vo.plugin_title = [dictionary objectForKey:@"title"];
	vo.plugin_info = [dictionary objectForKey:@"info"];
	vo.cost = [[dictionary objectForKey:@"cost"] floatValue];
	
	return (vo);
}

-(NSString *)price {
	return ((self.cost > 0.0) ? [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.cost] numberStyle:NSNumberFormatterCurrencyStyle] : @"FREE");
}

-(void)dealloc {
	self.dictionary = nil;
	self.plugin_title = nil;
	self.plugin_info = nil;
	
	[super dealloc];
}
@end
