//
//  SNNewsClient.h
//  SimpleNews
//
//  Created by Jesse Boley on 5/15/12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "AFNetworking.h"
#import "MBLAsyncResource.h"

@interface SNNewsClient : AFHTTPClient

+ (SNNewsClient *)client;

// @revisit Add profile management to this class

- (MBLAsyncResource *)popularLists;

@end
