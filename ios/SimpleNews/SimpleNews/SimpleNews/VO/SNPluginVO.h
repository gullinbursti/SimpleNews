//
//  SNPluginVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNPluginVO : NSObject

+(SNPluginVO *)pluginWithDictionary:(NSDictionary *)dictionary;
-(NSString *)price;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int plugin_id;
@property (nonatomic, retain) NSString *plugin_title;
@property (nonatomic, retain) NSString *plugin_info;
@property (nonatomic) float cost;


@end
