//
//  MBLResourceCache.h
//  MBLResourceLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

/** An asynchronous, persistent key-value store. */

@class MBLAsyncResource;

extern NSString * const MBLResourceCacheErrorDomain;
extern const NSInteger MBLResourceCacheError_KeyNotFound;

@interface MBLResourceCache : NSObject

/** Returns a global cache that uses the appropriate persistent directory. */
+ (MBLResourceCache *)sharedCache;

/** Returns a new cache using the specified directory. */
- (id)initWithCacheDirectory:(NSString *)cacheDirectory;

/** Inserts a new resource into the cache with the specified key and expiration date. */
- (void)insertResource:(NSData *)data forKey:(NSString *)key withExpiration:(NSDate *)expiration;

/** Inserts a JSON object into the cache with the specified key and expiration date. */
- (void)insertObject:(id)object forKey:(NSString *)key withExpiration:(NSDate *)expiration;

/** Retrieves a resource from the cache. Always returns immediately (see MBLAsyncResource). */
- (MBLAsyncResource *)fetchResourceForKey:(NSString *)key;

/** Returns the time that the key was added to the cache, or nil if the key isn't in the cache. */
- (NSDate *)fetchCreationDateForKey:(NSString *)key;

/** Removes a key from the cache. Does nothing if the key doesn't exist in the cache. */
- (void)removeResourceForKey:(NSString *)key;

/** Removes all resources from the cache. This method will block until it completes and may be slow. */
- (void)removeAllResources;

@end
