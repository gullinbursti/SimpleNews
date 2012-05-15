//
//  MBLResource.h
//  MBLAssetLoader
//
//  Copyright (c) 2012 Jesse Boley. All rights reserved.
//

#import "MBLTopic.h"
#import "MBLObserver.h"

// Resources make it easy to manually control a topic.

@interface MBLResource : MBLTopic <MBLObserver>

// Returns a new resource.
+ (id)resource;

@end
