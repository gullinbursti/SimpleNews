//
//  SNComposeFriendsView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

//#import <FBiOSSDK/FacebookSDK.h>
#import <FacebookSDK/FacebookSDK.h>

#import "SNComposeFriendsView.h"
#import "SNAppDelegate.h"
#import "SNFacebookThumbView.h"

@implementation SNComposeFriendsView

#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		if (FBSession.activeSession.isOpen) {
			//NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"2012-08-01T00%3A00%3A00%2B0000" forKey:@"since"];
			
			[FBRequestConnection startWithGraphPath:@"me/home" parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
				_fbHomeFeed = (NSDictionary *)result;
				
				if (error) {
					NSLog(@"error:[%@]", error.description);
				}
				
				//NSLog(@"data\n%@", (NSArray *)[_fbHomeFeed objectForKey:@"data"]);
				
				_friendHolderView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 50.0, 280.0, 400.0)];
				[self addSubview:_friendHolderView];
				
				NSMutableArray *photos = [NSMutableArray new];
				
				for (NSDictionary *entry in (NSArray *)[_fbHomeFeed objectForKey:@"data"]) {
					//NSLog(@"PHOTO:%@\n[%@]\n\n", [entry objectForKey:@"story"], [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [[entry objectForKey:@"from"] objectForKey:@"id"]]);
					
					NSString *fromID = [[entry objectForKey:@"from"] objectForKey:@"id"];
					NSString *fromName = [[entry objectForKey:@"from"] objectForKey:@"name"];
					NSString *largeImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fromID];
					NSString *squareImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", fromID];
					
					BOOL isFound = NO;
					for (NSDictionary *test in photos) {
						if ([[test objectForKey:@"id"] isEqualToString:fromID])
							isFound = YES;
					}
					
					if (!isFound)
						[photos addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:fromID, fromName, squareImgURL, largeImgURL, nil] forKeys:[NSArray arrayWithObjects:@"id", @"name", @"sq_image", @"lg_image", nil]]];
					
					int row = 0;
					int col = 0;
					int cnt = 0;
					for (NSDictionary *dict in photos) {
						row = cnt / 4;
						col = cnt % 4;
						
						SNFacebookThumbView *thumbView = [[SNFacebookThumbView alloc] initWithPosition:CGPointMake(col * 65.0, row * 65.0) fbUser:dict];
						[_friendHolderView addSubview:thumbView];
						
						cnt++;
					}
				}
			}];
		}
	}
	
	return (self);
}


@end
