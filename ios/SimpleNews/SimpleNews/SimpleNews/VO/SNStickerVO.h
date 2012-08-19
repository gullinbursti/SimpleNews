//
//  SNStickerVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.18.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNStickerVO : NSObject

+(SNStickerVO *)stickerWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int imageID;
@property (nonatomic) int topicID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;

@end
