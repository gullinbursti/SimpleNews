//
//  MBLAsyncResource.h
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBLAsyncResource;

@protocol MBLResourceObserverProtocol <NSObject>
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data;
- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error;
@end

@interface MBLAsyncResource : NSObject
- (id)initWithData:(NSData *)data;
- (id)initWithError:(NSError *)error;

- (void)subscribe:(id<MBLResourceObserverProtocol>)observer;
- (void)unsubscribe:(id<MBLResourceObserverProtocol>)observer;

- (void)onFinish:(void(^)(MBLAsyncResource *resource, NSData *data, NSError *error))handler;

- (BOOL)isValid;
- (void)sendError:(NSError *)error;
- (void)sendData:(NSData *)data;
@end
