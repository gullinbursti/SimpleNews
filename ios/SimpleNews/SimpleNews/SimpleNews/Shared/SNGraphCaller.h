//
//  SNGraphCaller.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Facebook.h"

@interface SNGraphCaller : NSObject <FBRequestDelegate> {
	
}

+(SNGraphCaller *) sharedInstance;


-(NSString *)postActivity:(NSString *)action withObject:(NSString *)object jobID:(NSString *)job_id;
-(NSString *)postFeed:(NSString *)message;
-(NSArray *)geoSearch:(NSString *)coords ofType:(NSString *)type withRadius:(int)dist;

-(NSDictionary *)sql:(NSString *)query;

@end
