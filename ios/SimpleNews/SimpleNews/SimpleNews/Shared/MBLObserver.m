//
//  MBLObserver.m
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import "MBLObserver.h"

@interface MBLObserver ()
@property(nonatomic, copy) void (^next)(id value);
@property(nonatomic, copy) void (^error)(NSError *error);
@property(nonatomic, copy) void (^completed)(void);
@end

@implementation MBLObserver

@synthesize next;
@synthesize error;
@synthesize completed;

+ (id)subscriberWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed
{
	MBLObserver *observer = [[self alloc] init];
	observer.next = next;
	observer.error = error;
	observer.completed = completed;
	return observer;
}

- (void)stopSubscription
{
	// @revisit Need to implement
}

- (void)dealloc
{
	[self stopSubscription];
}

- (void)sendNext:(id)value
{
	if (self.next != nil)
		self.next(value);
}

- (void)sendError:(NSError *)e
{
	[self stopSubscription];
	
	if (self.error != nil)
		self.error(e);
}

- (void)sendCompleted
{
	[self stopSubscription];
	
	if (self.completed != nil)
		self.completed();
}

@end
