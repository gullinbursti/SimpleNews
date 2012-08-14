//
//  SNFacebookCaller.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBiOSSDK/FacebookSDK.h>

#import "SNArticleVO.h"


@interface SNFacebookCaller : NSObject

+(void)postToActivity:(SNArticleVO *)vo withAction:(NSString *)action;
+(void)postStatus:(NSString *)msg;
+(void)postToTimeline:(SNArticleVO *)vo;
+(void)postToTicker:(NSString *)msg;

@end
