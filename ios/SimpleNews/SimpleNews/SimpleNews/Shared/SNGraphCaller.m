//
//  SNGraphCaller.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNGraphCaller.h"
#import "SNAppDelegate.h"

static SNGraphCaller *sharedInstance = nil;

@implementation SNGraphCaller

- (id)init {
	if ((self = [super init])) {
	}
	
	return self;
}

+(SNGraphCaller *)sharedInstance {
	
	if (!sharedInstance) {
		
		if ([[SNGraphCaller class] isEqual:[self class]])
			sharedInstance = [[SNGraphCaller alloc] init];
		
		else
			sharedInstance = [[self alloc] init];
	}
	
	return (sharedInstance);
}


-(NSString *)postActivity:(NSString *)action withObject:(NSString *)object jobID:(NSString *)job_id {
	NSLog(@"postActivity:[%@][%@]", [action lowercaseString], [object lowercaseString]);
	
	NSString *graph_id;
	//NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"http://dev.gullinbursti.cc/projs/oddjob/posts/%@.htm", action], object, nil];
	
	// post activity
	//if ([SNAppDelegate isProfileInfoAvailable])
		[[[SNAppDelegate sharedInstance] facebook] requestWithGraphPath:[NSString stringWithFormat:@"me/oddjobb:%@", [action lowercaseString]] andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"http://apps.facebook.com/oddjobb/?jID=%d", [job_id integerValue]], [object lowercaseString], nil] andHttpMethod:@"POST" andDelegate:self];
	
	//[[OJAppDelegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"me/oddjobb:%@", [action lowercaseString]] andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"http://dev.gullinbursti.cc/projs/oddjob/posts/%@.htm", [object lowercaseString]], [object lowercaseString], nil] andHttpMethod:@"POST" andDelegate:self];
	return (graph_id);
}

-(NSString *)postFeed:(NSString *)message {
	NSLog(@"postFeed:[%@]", message);
	
	NSString *graph_id;
	
	// post activity
	//if ([SNAppDelegate isProfileInfoAvailable])
		[[[SNAppDelegate sharedInstance] facebook] requestWithGraphPath:[NSString stringWithFormat:@"me/feed"] andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"feed", nil] andHttpMethod:@"POST" andDelegate:self];
	
	return (graph_id);	
}


-(NSArray *)geoSearch:(NSString *)coords ofType:(NSString *)type withRadius:(int)dist {
	NSLog(@"geoSearch:[%@][%@][%d]", coords, type, dist);
	
	NSArray *arrPlaces;
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:type, @"type", coords, @"center", [NSString stringWithFormat:@"%d", dist], @"distance", nil];
	
	// search location
	//if ([SNAppDelegate isProfileInfoAvailable])
		[[[SNAppDelegate sharedInstance] facebook] requestWithGraphPath:@"search" andParams:params andDelegate:self];
	
	return (arrPlaces);
	
	
	//1/2 moon bay
	//"latitude": 37.467041742753,
	//"longitude": -122.43202732618
	
	//NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"place", @"type", @"37.448,-122.163", @"center", @"1000", @"distance", nil];
}



-(NSDictionary *)sql:(NSString *)query {
	
	NSDictionary *dict;
	
	//if (![[SNAppDelegate facebook] accessToken])
		return (dict);
	
	
	//@"SELECT uid, name, pic FROM user WHERE uid=me()"
	
	[[[SNAppDelegate sharedInstance] facebook] requestWithMethodName:@"fql.query" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:query, @"query", nil] andHttpMethod:@"POST" andDelegate:self];
	
	
	return (dict);
}


#pragma mark - FBRequestDelegate Methods
- (void)requestLoading:(FBRequest *)request {
	
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"received response [%@]", [request responseText]);
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
	NSLog(@"Err code: %d", [error code]);
	NSLog(@"Err: %@", error);
	
	if ([error code] == 190)
		[[[SNAppDelegate sharedInstance] facebook] logout:[SNAppDelegate sharedInstance]];
	
	else
		NSLog(@"There was an error making your request.");
	
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	NSLog(@"Result: %@", result);
	
	
	NSMutableArray *places = [[NSMutableArray alloc] initWithCapacity:1];
	NSArray *resultData = [result objectForKey:@"data"];
	
	for (NSUInteger i=0; i<[resultData count] && i<5; i++)
		[places addObject:[resultData objectAtIndex:i]];
	
	[places release];
	
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
	
}

@end
