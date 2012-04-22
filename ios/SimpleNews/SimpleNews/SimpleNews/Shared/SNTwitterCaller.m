//
//  SNTwitterCaller.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTwitterCaller.h"

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#import "SNTweetVO.h"

static SNTwitterCaller *sharedInstance = nil;

@interface SNTwitterCaller()
-(void)_fetchData;
@end



@implementation SNTwitterCaller

@synthesize accounts = _accounts;
@synthesize accountStore = _accountStore;

@synthesize account = _account;
@synthesize timeline = _timeline;

+(SNTwitterCaller *)sharedInstance {
	if (!sharedInstance) {
		if ([[SNTwitterCaller class] isEqual:[self class]])
			sharedInstance = [[SNTwitterCaller alloc] init];
		
		else
			sharedInstance = [[self alloc] init];
	}
	
	return (sharedInstance);
}

-(id)init {
	if ((self = [super init])) {
		[self _fetchData];
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];
}


- (void)_fetchData {
	if (_accountStore == nil) {    
		self.accountStore = [[ACAccountStore alloc] init];
		if (_accounts == nil) {
			ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
			[self.accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
				if(granted) {
					self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
					self.account = [self.accounts objectAtIndex:0];
					
					NSLog(@"ACCOUNT:%@", self.account);
					
					//if (self.account) {
						[[NSUserDefaults standardUserDefaults] setObject:self.account.username forKey:@"twitterHandle"];
						[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=reasonably_small", self.account.username] forKey:@"twitterAvatar"];
						[[NSUserDefaults standardUserDefaults] synchronize];
					//}
					
					for (ACAccount *account in self.accounts) {
						//NSLog(@"USERNAME:%@", account.username);
						//NSLog(@"INFO:%@", account.accountDescription);
					}
					
//					dispatch_sync(dispatch_get_main_queue(), ^{
//						[self.tableView reloadData]; 
//					});
				}
			}];
		}
	}
}


-(void)userTimeline {
	NSLog(@"TIMELINE");
	
	if (_accountStore == nil) {
		self.accountStore = [[ACAccountStore alloc] init];
		if (_accounts == nil) {
			ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
			[self.accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
				if(granted) {
					self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
					self.account = [self.accounts objectAtIndex:0];
					
					NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/home_timeline.json"];
					TWRequest *request = [[TWRequest alloc] initWithURL:url  parameters:nil requestMethod:TWRequestMethodGET];
					[request setAccount:self.account];    
					[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
						if ([urlResponse statusCode] == 200) {
							NSMutableArray *tweets = [NSMutableArray new];
							
							NSError *jsonError = nil;
							NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
							if (jsonResult != nil) {
								self.timeline = jsonResult;
								
								for (NSDictionary *tweet in jsonResult) {
									//NSLog(@"%@", tweet);
									//NSLog(@"USERNAME:%@ [%@]", [tweet valueForKeyPath:@"user.name"], [tweet valueForKeyPath:@"user.profile_image_url"]);
									//NSLog(@"INFO:%@", [tweet objectForKey:@"text"]);
									
									SNTweetVO *vo = [SNTweetVO tweetWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[tweet objectForKey:@"id"], @"tweet_id", [tweet valueForKeyPath:@"user.name"], @"author", [tweet valueForKeyPath:@"user.profile_image_url"], @"avatar", [tweet objectForKey:@"text"], @"content", nil]];
									[tweets addObject:vo];
								}
								
								[[NSNotificationCenter defaultCenter] postNotificationName:@"TWITTER_TIMELINE" object:tweets];
								
							} else {
								NSString *message = [NSString stringWithFormat:@"Could not parse your timeline: %@", [jsonError localizedDescription]];
								[[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
							}
						}
					}];
					
					
					for (ACAccount *account in self.accounts) {
						//NSLog(@"USERNAME:%@", account.username);
						//NSLog(@"INFO:%@", account.accountDescription);
					}
					
					//					dispatch_sync(dispatch_get_main_queue(), ^{
					//						[self.tableView reloadData]; 
					//					});
				}
			}];
		}
	}
}

@end
