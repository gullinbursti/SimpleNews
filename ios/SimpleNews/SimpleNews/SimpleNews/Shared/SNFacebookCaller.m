//
//  SNFacebookCaller.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.14.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFacebookCaller.h"
#import "SNImageVO.h"

@implementation SNFacebookCaller

+(void)postStatus:(NSString *)msg {
	NSDictionary *params = [NSDictionary dictionaryWithObject:msg forKey:@"message"];
	[FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		NSLog(@"POSTED STATUS");
	}];
}

+(void)postToActivity:(SNArticleVO *)vo withAction:(NSString *)action {
	NSMutableDictionary *params = [NSMutableDictionary new];
	[params setObject:[NSString stringWithFormat:@"http://discover.getassembly.com/facebook/opengraph/index.php?aID=%d", vo.article_id] forKey:@"quote"];
	[params setObject:((SNImageVO *)[vo.images objectAtIndex:0]).url forKey:@"image[0][url]"];
	
	[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/getassembly:%@", action] parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		NSLog(@"POSTED TO ACTVITY :[%@]",[result objectForKey:@"id"]);
		
		if (error) {
			[[[UIAlertView alloc] initWithTitle:@"Result" message:[NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];	
		}
	}];
}

+(void)postToTicker:(NSString *)msg {
	
}

+(void)postToTimeline:(SNArticleVO *)vo {
	NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
												  [NSString stringWithFormat:@"http://discover.getassembly.com/facebook/opengraph/index.php?aID=%d", vo.article_id], @"link",
												  ((SNImageVO *)[vo.images objectAtIndex:0]).url, @"picture",
												  vo.title, @"name",
												  vo.topicTitle, @"caption",
												  vo.content, @"description", nil];
	
	[FBRequestConnection startWithGraphPath:@"me/feed" parameters:postParams HTTPMethod:@"POST" completionHandler:
	 ^(FBRequestConnection *connection, id result, NSError *error) {
		 NSString *alertText;
		 
		 if (error)
			 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
		 
		 else
			 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
		 
		 
		 [[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
	 }];
	
	
//	id<SNOGArticle> articleObject = (id<SNOGArticle>)[FBGraphObject graphObject];
//	articleObject.url = [NSString stringWithFormat:@"http://discover.getassembly.com/facebook/opengraph/index.php?aID=%d", _articleVO.article_id];
//	
//	id<SNOGShareArticleAction> action = (id<SNOGShareArticleAction>)[FBGraphObject graphObject];
//	action.article = articleObject;
//	
//	NSMutableDictionary *image = [[NSMutableDictionary alloc] init];
//	[image setObject:((SNImageVO *)[_articleVO.images objectAtIndex:0]).url forKey:@"url"];
//	
//	NSMutableArray *images = [[NSMutableArray alloc] init];
//	[images addObject:image];
//	
//	action.image = images;
//	
//	[FBRequest startForPostWithGraphPath:@"me/getassembly:share" graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {			 
//		NSString *alertText;
//		
//		if (!error)
//			alertText = [NSString stringWithFormat:@"Posted Open Graph action, id: %@", [result objectForKey:@"id"]];
//		
//		else
//			alertText = [NSString stringWithFormat:@"error: domain = %@, code = %d", error.description, error.code];
//		
//		[[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:nil cancelButtonTitle:@"Thanks!" otherButtonTitles:nil] show];
//	}];

}

+(void)postToFriendTimeline:(NSString *)fbID article:(SNArticleVO *)vo {
	NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
												  [NSString stringWithFormat:@"http://discover.getassembly.com/facebook/opengraph/index.php?aID=%d", vo.article_id], @"link",
												  ((SNImageVO *)[vo.images objectAtIndex:0]).url, @"picture",
												  vo.title, @"name",
												  vo.topicTitle, @"caption",
												  vo.content, @"description", nil];
	
	[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", fbID] parameters:postParams HTTPMethod:@"POST" completionHandler:
	 ^(FBRequestConnection *connection, id result, NSError *error) {
		 NSString *alertText;
		 
		 if (error)
			 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
		 
		 else
			 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
		 
		 
		 [[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
	 }];
}

+(void)postMessageToFriendTimeline:(NSString *)fbID message:(NSString *)msg {
	NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
												  msg, @"message", 
												  @"http://discover.getassembly.com", @"link",
												  @"name here", @"name",
												  @"caption", @"caption",
												  @"info", @"description", nil];
	
	[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", fbID] parameters:postParams HTTPMethod:@"POST" completionHandler:
	 ^(FBRequestConnection *connection, id result, NSError *error) {
		 NSString *alertText;
		 
		 if (error)
			 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
		 
		 else
			 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
		 
		 
		 [[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
	 }];
}


@end
