//
//  MBLObserver.h
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACDisposable;

@protocol MBLObserver <NSObject>
- (void)sendNext:(id)value;
- (void)sendError:(NSError *)error;
- (void)sendCompleted;
@end

@interface MBLObserver : NSObject <MBLObserver>
// Creates a new subscriber with the given blocks.
+ (id)subscriberWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed;
@end

