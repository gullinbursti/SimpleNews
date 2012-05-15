//
//  MBLResource.m
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import "MBLResource.h"

@implementation MBLResource

+ (id)resource
{
	return [[self alloc] init];
}

- (void)sendNext:(id)value
{
	[self performBlockOnEachSubscriber:^(id<MBLObserver> observer) {
		[observer sendNext:value];
	}];
}

- (void)sendError:(NSError *)error
{
	[self _stopSubscription];
	
	[self performBlockOnEachSubscriber:^(id<MBLObserver> observer) {
		[observer sendError:error];
	}];
}

- (void)sendCompleted
{
	[self _stopSubscription];
	
	[self performBlockOnEachSubscriber:^(id<MBLObserver> observer) {
		[observer sendCompleted];
	}];
}

- (void)_stopSubscription
{
	// @revisit clean up
}

@end
