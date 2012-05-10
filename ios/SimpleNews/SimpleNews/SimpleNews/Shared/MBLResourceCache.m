//
//  MBLResourceCache.m
//  MBLResourceLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "MBLResourceCache.h"
#import "MBLAsyncResource.h"

NSString * const kMBLResourceCacheIndexFilename = @"MBLResourceCacheIndex";
NSString * const MBLResourceCacheErrorDomain = @"MBLResourceCacheErrorDomain";
const NSInteger MBLResourceCacheError_KeyNotFound = 1000;
const NSInteger MBLResourceCacheError_FileNotFound = 1001;

NSString * const _MBLCacheEntryCreatedKey = @"created";
NSString * const _MBLCacheEntryExpiresKey = @"expires";

@interface MBLFileResource : MBLAsyncResource
{
	BOOL _didLoad;
	NSString *_path;
}
- (id)initWithPath:(NSString *)path;
- (void)startLoading;
@end

@interface MBLResourceCache ()
{
	NSString *_cacheDirectory;
	NSMutableDictionary *_mruRequests;
	NSMutableDictionary *_index;
	dispatch_queue_t _queue;
}
@end

@implementation MBLResourceCache

+ (NSString *)_defaultCacheDirectory
{
#if TARGET_OS_IPHONE
	return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MBLResourceCache"];
#else
	NSAssert(NO, @"Set up cache directory for OS X");
#endif
}

+ (MBLResourceCache *)sharedCache
{
	static MBLResourceCache *s_sharedCache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_sharedCache = [[MBLResourceCache alloc] initWithCacheDirectory:[self _defaultCacheDirectory]];
	});
	return s_sharedCache;
}

- (NSString *)_pathForIndexFile
{
	return [_cacheDirectory stringByAppendingPathComponent:kMBLResourceCacheIndexFilename];
}

- (id)initWithCacheDirectory:(NSString *)cacheDirectory
{
	if ((self = [super init])) {
		_cacheDirectory = cacheDirectory;
		NSAssert(_cacheDirectory != nil, @"Must specify a valid cache directory path");
		[[NSFileManager defaultManager] createDirectoryAtPath:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		
		// Check the cache directory for an index file
		NSString *indexPath = [self _pathForIndexFile];
		if ([[NSFileManager defaultManager] fileExistsAtPath:indexPath])
			_index = [NSMutableDictionary dictionaryWithContentsOfFile:indexPath];
		else
			_index = [[NSMutableDictionary alloc] init];
		
		// Use a queue to protect the index dictionary
		_queue = dispatch_queue_create("com.mblresources.index", DISPATCH_QUEUE_CONCURRENT);
	}
	return self;
}

- (NSString *)_cacheIdentifierForKey:(NSString *)key
{
	const char *str = [key UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);
	
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

- (NSString *)_cachePathForKey:(NSString *)key
{
	return [_cacheDirectory stringByAppendingPathComponent:[self _cacheIdentifierForKey:key]];
}

- (void)insertResource:(NSData *)data forKey:(NSString *)key withExpiration:(NSDate *)expiration
{
	dispatch_barrier_async(_queue, ^{
		// Try writing the resource to disk before anything else
		NSString *path = [self _cachePathForKey:key];
		if ([data writeToFile:path atomically:YES]) {
			// File written successfully, update the index
			NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], _MBLCacheEntryCreatedKey, 
								   expiration, _MBLCacheEntryExpiresKey, nil];
			[_index setObject:entry forKey:key];
			[_index writeToFile:[self _pathForIndexFile] atomically:YES];
			
			// @revisit Add entry to MRU cache
			
			// @revisit We flush the index to disk immediately but we should really schedule it with an idle notification
			// and also implement a termination handler
		}
		else {
			NSLog(@"Failed to write resource to disk with key %@", key);
		}
	});
}

- (BOOL)_isKeyStale:(NSString *)key
{
	NSDictionary *entry = [_index objectForKey:key];
	NSDate *expires = [entry objectForKey:_MBLCacheEntryExpiresKey];
	return ((entry == nil) || ((expires != nil) && ([expires compare:[NSDate date]] == NSOrderedAscending)));
}

- (MBLAsyncResource *)fetchResourceForKey:(NSString *)key
{
	__block MBLAsyncResource *resource = nil;
	
	// Check the cache for the key
	dispatch_sync(_queue, ^{
		if ([self _isKeyStale:key]) {
			[self removeResourceForKey:key]; // Won't deadlock because -removeResourceForKey: uses a dispatch_async call
			resource = [[MBLAsyncResource alloc] initWithError:[NSError errorWithDomain:MBLResourceCacheErrorDomain code:MBLResourceCacheError_KeyNotFound userInfo:nil]];
		}
		else {
			// @revisit Convert to async load from disk
			MBLFileResource *fileResource = [[MBLFileResource alloc] initWithPath:[self _cachePathForKey:key]];
			[fileResource startLoading];
			resource = fileResource;
		}
	});
	
	return resource;
}

- (NSDate *)fetchCreationDateForKey:(NSString *)key
{
	__block NSDate *result = nil;
	dispatch_sync(_queue, ^{
		result = [[_index objectForKey:key] objectForKey:_MBLCacheEntryCreatedKey];
	});
	return result;
}

- (void)removeResourceForKey:(NSString *)key
{
	dispatch_barrier_async(_queue, ^{
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSString *path = [self _cachePathForKey:key];
		[fileManager removeItemAtPath:path error:nil];
		
		[_index removeObjectForKey:key];
		[_index writeToFile:[self _pathForIndexFile] atomically:YES];
	});
}

- (void)removeAllResources
{
	dispatch_barrier_async(_queue, ^{
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		for (NSString *key in _index)
			[fileManager removeItemAtPath:[self _cachePathForKey:key] error:nil];
		[_index removeAllObjects];
	});
}

@end

@implementation MBLFileResource

- (id)initWithPath:(NSString *)path
{
	if ((self = [super init])) {
		_path = path;
	}
	return self;
}

- (void)startLoading
{
	if (!_didLoad) {
		_didLoad = YES;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			NSData *data = [NSData dataWithContentsOfFile:_path];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (data == nil)
					[self sendError:[NSError errorWithDomain:MBLResourceCacheErrorDomain code:MBLResourceCacheError_FileNotFound userInfo:nil]];
				else
					[self sendData:data];
			});
		});
	}
}

@end
