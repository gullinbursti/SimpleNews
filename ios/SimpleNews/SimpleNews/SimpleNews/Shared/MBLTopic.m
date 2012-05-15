//
//  MBLTopic.m
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import "MBLTopic.h"
#import "MBLObserver.h"

// Set of "in-flight" topics
static NSMutableSet *s_activeTopics = nil;

@interface MBLTopic ()
@property(assign, getter=isTearingDown) BOOL tearingDown;
@end

@implementation MBLTopic

@synthesize didSubscribe;
@synthesize observers;
@synthesize tearingDown;

+ (void)initialize
{
	if (self == [MBLTopic class])
		s_activeTopics = [NSMutableSet set];
}

- (id)init
{
	if ((self = [super init])) {
		@synchronized(s_activeTopics) {
			[s_activeTopics addObject:self];
		}
		self.observers = [NSMutableArray array];
		[self _checkForNoObservers];
	}
	return self;
}

- (void)_checkForNoObservers
{
	[self performSelector:@selector(_invalidateIfNoObservers) withObject:nil afterDelay:0.0];
}

- (void)_invalidateIfNoObservers
{
	BOOL hasSubscribers = NO;
	@synchronized(self.observers) {
		hasSubscribers = self.observers.count >= 1;
	}
	
	if (!hasSubscribers) {
		@synchronized(s_activeTopics) {
			[s_activeTopics removeObject:self];
		}
	}
}

- (void)subscribe:(id<MBLObserver>)observer
{
	NSParameterAssert(observer != nil);
	
	@synchronized(self.observers) {
		[self.observers addObject:observer];
	}
	
	if (self.didSubscribe != nil) {
		self.didSubscribe(observer);
	}
}

+ (id)createTopic:(void (^)(id<MBLObserver> observer))didSubscribe
{
	MBLTopic *topic = [[self alloc] init];
	topic.didSubscribe = didSubscribe;
	return topic;
}

+ (id)return:(id)value
{
	return [self createTopic:^(id<MBLObserver> observer) {
		[observer sendNext:value];
		[observer sendCompleted];
	}];
}

+ (id)error:(NSError *)error
{
	return [self createTopic:^(id<MBLObserver> observer) {
		[observer sendError:error];
	}];
}

+ (id)empty
{
	return [self createTopic:^(id<MBLObserver> observer) {
		[observer sendCompleted];
	}];
}

+ (id)never
{
	return [self createTopic:^(id<MBLObserver> observer){}];
}

+ (id)start:(id (^)(BOOL *success, NSError **error))block
{
	NSParameterAssert(block != NULL);
	
	// Send back an async resource.
	
	return nil;
}

- (void)performBlockOnEachSubscriber:(void (^)(id<MBLObserver> observer))block
{
	NSParameterAssert(block != NULL);
	
	NSArray *currentObservers = nil;
	@synchronized(self.observers) {
		currentObservers = [self.observers copy];
	}
	
	for(id<MBLObserver> observer in currentObservers) {
		block(observer);
	}
}

- (void)tearDown
{
	self.tearingDown = YES;
	
	@synchronized(self.observers) {
		[self.observers removeAllObjects];
	}
	
	@synchronized(s_activeTopics) {
		[s_activeTopics removeObject:self];
	}
}

@end
