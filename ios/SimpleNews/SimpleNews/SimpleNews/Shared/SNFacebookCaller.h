//
//  SNFacebookCaller.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FBiOSSDK/FacebookSDK.h>
#import <FacebookSDK/FacebookSDK.h>

#import "SNArticleVO.h"


@interface SNFacebookCaller : NSObject

+(void)postToActivity:(SNArticleVO *)vo withAction:(NSString *)action;
+(void)postStatus:(NSString *)msg;
+(void)postToTimeline:(SNArticleVO *)vo;
+(void)postToTicker:(NSString *)msg;
+(void)postToFriendTimeline:(NSString *)fbID article:(SNArticleVO *)vo;
+(void)postMessageToFriendTimeline:(NSString *)fbID message:(NSString *)msg;

@end
