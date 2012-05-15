//
//  SNNewsClient.m
//  SimpleNews
//
//  Created by Jesse Boley on 5/15/12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNNewsClient.h"
#import "SNAppDelegate.h"

#import "MBLResourceCache.h"

@implementation SNNewsClient

+ (SNNewsClient *)client
{
	static SNNewsClient *s_client = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_client = [[SNNewsClient alloc] initWithBaseURL:[NSURL URLWithString:kServerPath]];
	});
	return s_client;
}

- (id)initWithBaseURL:(NSURL *)url
{
	if ((self = [super initWithBaseURL:url])) {
		self.parameterEncoding = AFFormURLParameterEncoding; // Parameters are encoded using form data
		
		// We expect all requests to return JSON.
		[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
		[self setDefaultHeader:@"Accept" value:@"application/json"];
	}
	return self;
}

- (MBLAsyncResource *)popularLists
{
	NSString *userId = [[SNAppDelegate profileForUser] objectForKey:@"id"];
	NSMutableDictionary *popularListFormValues = [NSMutableDictionary dictionary];
	[popularListFormValues setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
	[popularListFormValues setObject:(userId != nil ? userId : [NSString stringWithFormat:@"%d", 0]) forKey:@"userID"];
	return [self _enqueueRequestWithMethod:@"POST" path:@"lists.php" parameters:popularListFormValues expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0)]];
}

- (MBLAsyncResource *)_enqueueRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters expiration:(NSDate *)expiration
{
	// Check the cache first
	NSString *cacheKey = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
	MBLAsyncResource *resource = [[MBLResourceCache sharedCache] fetchResourceForKey:cacheKey];
	
	if (resource == nil) {
		resource = [MBLAsyncResource resource];
		
		NSURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
		AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
			[[MBLResourceCache sharedCache] insertObject:responseObject forKey:cacheKey withExpiration:expiration];
			[resource sendNext:responseObject];
			[resource sendCompleted];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[resource sendError:error];
		}];
		
		[self enqueueHTTPRequestOperation:operation];
	}
	
	return resource;
}


@end
