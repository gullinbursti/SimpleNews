//
//  MBLAsyncResource.m
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import "MBLAsyncResource.h"

@interface _MBLAsyncResourceHandler : NSObject <MBLResourceObserverProtocol>
@property(nonatomic, copy) void(^handler)(MBLAsyncResource *resource, NSData *data, NSError *error);
@end

@interface MBLAsyncResource ()
{
	NSMutableArray *_subscribers;
	dispatch_queue_t _queue;
	NSError *_error;
	NSData *_data;
}
@end

@implementation MBLAsyncResource

- (id)init
{
	if ((self = [super init])) {
		_subscribers = [[NSMutableArray alloc] init];
		_queue = dispatch_queue_create("com.mbl.asyncresource", DISPATCH_QUEUE_CONCURRENT);
	}
	return self;
}

- (id)initWithData:(NSData *)data
{
	if ([self init]) {
		_data = data;
	}
	return self;
}

- (id)initWithError:(NSError *)error
{
	if ([self init]) {
		_error = error;
	}
	return self;
}

- (void)dealloc
{
	dispatch_release(_queue);
	_queue = nil;
    _error = nil;
	_data = nil;
	_subscribers = nil;
}

- (void)subscribe:(id<MBLResourceObserverProtocol>)observer
{
	dispatch_barrier_async(_queue, ^{
		[_subscribers addObject:observer];
	});
	
	// Immediately send results for new subscribers
	if (_error != nil)
		[observer resource:self didFailWithError:_error];
	else if (_data != nil)
		[observer resource:self isAvailableWithData:_data];
}

- (void)unsubscribe:(id<MBLResourceObserverProtocol>)observer
{
	dispatch_barrier_async(_queue, ^{
		[_subscribers removeObject:observer];
	});
}

- (void)onFinish:(void(^)(MBLAsyncResource *resource, NSData *data, NSError *error))handler
{
	_MBLAsyncResourceHandler *callback = [[_MBLAsyncResourceHandler alloc] init];
	callback.handler = handler;
	[self subscribe:callback];
}

- (BOOL)isValid
{
	return (_error == nil);
}

- (void)sendError:(NSError *)error
{
	_error = error;
	
	__block NSArray *subscribers = nil;
	dispatch_sync(_queue, ^{
		subscribers = [NSArray arrayWithArray:_subscribers];
	});
	
	for (id<MBLResourceObserverProtocol>subscriber in subscribers)
		[subscriber resource:self didFailWithError:error];
}

- (void)sendData:(NSData *)data
{
	_data = data;
	
	__block NSArray *subscribers = nil;
	dispatch_sync(_queue, ^{
		subscribers = [NSArray arrayWithArray:_subscribers];
	});
	
	for (id<MBLResourceObserverProtocol>subscriber in subscribers)
		[subscriber resource:self isAvailableWithData:data];
}

@end

@implementation _MBLAsyncResourceHandler

@synthesize handler;

- (void)dealloc
{
	handler = nil;
}

- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data
{
	if (handler != nil)
		handler(resource, data, nil);
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error
{
	if (handler != nil)
		handler(resource, nil, error);
}

@end
