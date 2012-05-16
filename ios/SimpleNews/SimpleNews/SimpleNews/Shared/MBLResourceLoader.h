//
//  MBLResourceLoader.h
//  MBLResourceLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBLResourceCache.h"

/** Fast, asynchronous loading of remote resources. */

@interface MBLResourceLoader : NSObject

/** Returns a global resource loader that can be used for fetching network resources. */
+ (MBLResourceLoader *)sharedInstance;

/** Sets a specific instance for the resource cache. Otherwise, +sharedCache will be used. */
- (void)setResourceCache:(MBLResourceCache *)cache;

/** Returns the current cache associated with the resource loader. */
- (MBLResourceCache *)resourceCache;

/** 
 *  Downloads the data from the specified URL. If the data is already cached, that value is returned instead.
 *  The cache key is the URL itself. Setting forceFetch to YES will always download from the network and skip checking the cache.
 *  If new data is downloaded from the URL, it will be placed in the cache. You can set the expiration date for this cache entry.
 */
- (MBLAsyncResource *)downloadURL:(NSString *)url forceFetch:(BOOL)forceFetch expiration:(NSDate *)expiration;
- (MBLAsyncResource *)downloadURL:(NSString *)url withHeaders:(NSDictionary *)headers withPostFields:(NSDictionary *)postFields forceFetch:(BOOL)forceFetch expiration:(NSDate *)expiration;

@end
