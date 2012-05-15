//
//  MBLAsyncResource.m
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import "MBLAsyncResource.h"

const NSString * MBLAsyncResourceValueLockToken = @"MBLAsyncResourceValueLockToken";

@interface MBLAsyncResource ()
@property(nonatomic, strong) id value;
@property(assign) BOOL didComplete;
@property(strong) NSError *error;
@end

@implementation MBLAsyncResource

@synthesize value = _value;
@synthesize didComplete = _didComplete;
@synthesize error = _error;

- (void)subscribe:(id<MBLObserver>)observer
{
	[super subscribe:observer];
	
	if (_didComplete)
		[self sendCompleted];
	else if (_error != nil)
		[self sendError:_error];
}

- (void)sendNext:(id)value
{
	@synchronized(MBLAsyncResourceValueLockToken) {
		self.value = value;
	}
}

- (void)sendCompleted
{
	self.didComplete = YES;
	
	@synchronized(MBLAsyncResourceValueLockToken) {
		[super sendNext:_value];
	}
	
	[super sendCompleted];
}

- (void)sendError:(NSError *)e
{
	[super sendError:e];
	
	self.error = e;
}

//- (void)unsubscribe:(id<MBLResourceObserverProtocol>)observer
//{
//	dispatch_barrier_async(_queue, ^{
//		[_subscribers removeObject:observer];
//	});
//}

@end
