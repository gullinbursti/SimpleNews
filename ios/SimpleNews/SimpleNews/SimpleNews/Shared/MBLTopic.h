//
//  MBLTopic.h
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBLObserver;

@protocol MBLTopic <NSObject>
// Subscribes subscriber to changes on the receiver. The receiver defines which
// events it actually sends and in what situations the events are sent.
//
// Returns a disposable. You can call -dispose on it if you need to end your
// subscription before it would otherwise end.
- (void)subscribe:(id<MBLObserver>)observer;
@end


@interface MBLTopic : NSObject <MBLTopic>

// Creates a brand new resource that executes didSubscribe block whenever a new subscriber is added
+ (id)createTopic:(void (^)(id<MBLObserver> observer))didSubscribe;

// Convenience resources

// Returns a resource that immediately sends the specified value.
+ (id)return:(id)value;

// Returns a resource that immediately send the given error.
+ (id)error:(NSError *)error;

// Returns a resource that immediately completes.
+ (id)empty;

// Returns a resource that never completes.
+ (id)never;

// Returns a resource that calls the block in a background queue. The
// block's success is YES by default. If the block sets success = NO, the
// subscribable sends error with the error passed in by reference.
+ (id)start:(id (^)(BOOL *success, NSError **error))block;


// Private API @revisit Move to separate file

@property(nonatomic, copy) void (^didSubscribe)(id<MBLObserver> observer);
@property(nonatomic, strong) NSMutableArray *observers;

- (void)performBlockOnEachSubscriber:(void (^)(id<MBLObserver> observer))block;

- (void)tearDown;

@end
