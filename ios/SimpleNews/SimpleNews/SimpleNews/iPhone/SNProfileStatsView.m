//
//  SNProfileStatsView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.24.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNProfileStatsView.h"
#import "SNAppDelegate.h"

@implementation SNProfileStatsView

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		UIImageView *statsBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 84.0)];
		statsBgView.image = [UIImage imageNamed:@"profileBackgroundStats.png"];
		statsBgView.clipsToBounds = YES;
		[self addSubview:statsBgView];
		
		_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 23.0, 97.0, 18.0)];
		_commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18];
		_commentsLabel.textAlignment = UITextAlignmentCenter;
		_commentsLabel.textColor = [UIColor blackColor];
		_commentsLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_commentsLabel];
		
		UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 43.0, 97.0, 18.0)];
		commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		commentsLabel.textAlignment = UITextAlignmentCenter;
		commentsLabel.textColor = [SNAppDelegate snLinkColor];
		commentsLabel.backgroundColor = [UIColor clearColor];
		commentsLabel.text = @"Comments";
		[self addSubview:commentsLabel];
		
		_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 23.0, 100.0, 18.0)];
		_likesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18];
		_likesLabel.textAlignment = UITextAlignmentCenter;
		_likesLabel.textColor = [UIColor blackColor];
		_likesLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_likesLabel];
		
		UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 43.0, 100.0, 18.0)];
		likesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		likesLabel.textAlignment = UITextAlignmentCenter;
		likesLabel.textColor = [SNAppDelegate snLinkColor];
		likesLabel.backgroundColor = [UIColor clearColor];
		likesLabel.text = @"Likes";
		[statsBgView addSubview:likesLabel];
		
		_sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 23.0, 97.0, 18.0)];
		_sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18];
		_sharesLabel.textAlignment = UITextAlignmentCenter;
		_sharesLabel.textColor = [UIColor blackColor];
		_sharesLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_sharesLabel];
		
		UILabel *sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 43.0, 97.0, 18.0)];
		sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		sharesLabel.textAlignment = UITextAlignmentCenter;
		sharesLabel.textColor = [SNAppDelegate snLinkColor];
		sharesLabel.backgroundColor = [UIColor clearColor];
		sharesLabel.text = @"Shares";
		[self addSubview:sharesLabel];
		
		ASIFormDataRequest *statsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kUsersAPI]]];
		[statsRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
		[statsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[statsRequest setDelegate:self];
		[statsRequest startAsynchronous];
	}
	
	return (self);
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNFriendProfileViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *parsedStats = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			_likesLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"likes"] intValue]];
			_commentsLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"comments"] intValue]];
			_sharesLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"shares"] intValue]];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}
@end
