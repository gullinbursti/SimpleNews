//
//  MBLResourceLoader.m
//  MBLResourceLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import "MBLResourceLoader.h"
#import "MBLAsyncResource.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface MBLNetworkResource : MBLAsyncResource <ASIHTTPRequestDelegate>
{
	__weak MBLResourceLoader *_loader;
	NSString *_url;
	NSDate *_expiration;
	ASIHTTPRequest *_request;
}
- (id)initWithURL:(NSString *)url headers:(NSDictionary *)headers postFields:(NSDictionary *)postFields expiration:(NSDate *)expiration loader:(MBLResourceLoader *)loader;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSDate *expiration;
@end

@interface MBLResourceLoader ()
{
	NSMutableDictionary *_inflightRequests;
	dispatch_queue_t _queue;
	MBLResourceCache *_cache;
}
@end

@implementation MBLResourceLoader

+ (MBLResourceLoader *)sharedInstance
{
	static MBLResourceLoader *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[MBLResourceLoader alloc] init];
		
	});
	return s_sharedInstance;
}

- (id)init
{
	if ((self = [super init])) {
		_inflightRequests = [[NSMutableDictionary alloc] init];
		_queue = dispatch_queue_create("com.mblresources.loader", DISPATCH_QUEUE_CONCURRENT);
		[self setResourceCache:[MBLResourceCache sharedCache]];
	}
	return self;
}

- (void)dealloc
{
    dispatch_release(_queue);
	_queue = nil;
	_inflightRequests = nil;
	_cache = nil;
}

- (MBLResourceCache *)resourceCache
{
	return _cache;
}

- (void)setResourceCache:(MBLResourceCache *)cache
{
	_cache = cache;
}

- (MBLAsyncResource *)downloadURL:(NSString *)url forceFetch:(BOOL)forceFetch expiration:(NSDate *)expiration
{
	return [self downloadURL:url withHeaders:nil withPostFields:nil forceFetch:forceFetch expiration:expiration];
}

- (MBLAsyncResource *)downloadURL:(NSString *)url withHeaders:(NSDictionary *)headers withPostFields:(NSDictionary *)postFields forceFetch:(BOOL)forceFetch expiration:(NSDate *)expiration
{
	__block MBLAsyncResource *resource = nil;
	if (!forceFetch)
		resource = [_cache fetchResourceForKey:url];
	
	if ((resource == nil) || ![resource isValid]) {
        dispatch_sync(_queue, ^{
            resource = [_inflightRequests objectForKey:url];
        });
		
		// No in-flight requests so we need to start a new one
		if (resource == nil) {
			MBLNetworkResource *networkResource = [[MBLNetworkResource alloc] initWithURL:url headers:headers postFields:postFields expiration:expiration loader:self];
			dispatch_barrier_async(_queue, ^{
				[_inflightRequests setObject:networkResource forKey:url];
			});
			resource = networkResource;
		}
	}
	
	return resource;
}

- (void)_networkResource:(MBLNetworkResource *)resource didFinishWithData:(NSData *)data
{
	dispatch_barrier_async(_queue, ^{
		NSString *url = resource.url;
		if (data != nil)
			[_cache insertResource:data forKey:url withExpiration:resource.expiration];
		[_inflightRequests removeObjectForKey:url];
	});
}

@end

@implementation MBLNetworkResource

@synthesize url = _url;
@synthesize expiration = _expiration;

- (id)initWithURL:(NSString *)url headers:(NSDictionary *)headers postFields:(NSDictionary *)postFields expiration:(NSDate *)expiration loader:(MBLResourceLoader *)loader
{
	if ((self = [super init])) {
		_loader = loader;
		_expiration = expiration;
		_url = url;
		
		if ([postFields count] == 0)
			_request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
		else
			_request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
		[_request setDelegate:self];
		for (NSString *headerKey in headers)
			[_request addRequestHeader:headerKey value:[[headers objectForKey:headerKey] description]];
		for (NSString *postFieldKey in postFields)
			[(ASIFormDataRequest *)_request addPostValue:[postFields objectForKey:postFieldKey] forKey:postFieldKey];
		[_request startAsynchronous];
	}
	return self;
}

- (void)dealloc
{
	_loader = nil;
	_url = nil;
	[_request setDelegate:nil];
	[_request cancel];
	_request = nil;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	if (request == _request) {
		// Store the response data in the cache
		NSData *data = [request responseData];
		[_loader _networkResource:self didFinishWithData:data];
		[self sendData:data];
		
		[_request setDelegate:nil];
		_request = nil;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	if (request == _request) {
		[_loader _networkResource:self didFinishWithData:nil];
		[self sendError:[request error]];
		
		[_request setDelegate:nil];
		_request = nil;
	}
}

@end