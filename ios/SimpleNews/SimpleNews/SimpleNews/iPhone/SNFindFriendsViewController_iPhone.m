//
//  SNFindFriendsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNAppDelegate.h"

#import "SNFindFriendsViewController_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNTwitterFriendViewCell_iPhone.h"
#import "SNTwitterUserVO.h"
#import "SNTwitterFriendArticlesViewController_iPhone.h"
#import "SNFriendProfileViewController_iPhone.h"
#import "SNTwitterCaller.h"

@implementation SNFindFriendsViewController_iPhone

- (id)initAsFinder {
	if ((self = [self init])) {
		_isFinder = YES;
	}
	
	return (self);
}

- (id)initAsList {
	if ((self = [self init])) {
		_isFinder = NO;
	}
	
	return (self);
}

- (id)init {
	if ((self = [super init])) {
		_friends = [NSMutableArray new];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, self.view.frame.size.width, self.view.frame.size.height - 45.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	//_tableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	SNHeaderView_iPhone *headerView;
	
	if (_isFinder) {
		headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Find Friends"];
		[self.view addSubview:headerView];	
		
		_idsRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/followers/ids.json?id=%@", [SNAppDelegate twitterID]]]];
		_idsRequest.delegate = self;
		[_idsRequest startAsynchronous];
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_progressHUD.labelText = NSLocalizedString(@"Loading Following…", @"Status message when loading following list");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
	
	} else {
		headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"My Friends"];
		[self.view addSubview:headerView];
		
		_myFriendsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]];
		[_myFriendsRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
		[_myFriendsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_myFriendsRequest setDelegate:self];
		[_myFriendsRequest startAsynchronous];
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_progressHUD.labelText = NSLocalizedString(@"Loading Friends…", @"Status message when loading friend list");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
	}
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

#pragma mark Naviagation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_friends count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNTwitterFriendViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNTwitterFriendViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNTwitterFriendViewCell_iPhone alloc] init];
	cell.twitterUserVO = (SNTwitterUserVO *)[_friends objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return (53.0);
//}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SNTwitterUserVO *vo = (SNTwitterUserVO *)[_friends objectAtIndex:indexPath.row];
	NSLog(@"SELECTED:[%@]", vo.twitterID);
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	
	if (_isFinder) {
		_selectedIndex = indexPath.row;
		
		_friendLookupRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]];
		[_friendLookupRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[_friendLookupRequest setPostValue:vo.twitterID forKey:@"twitterID"];
		[_friendLookupRequest setDelegate:self];
		[_friendLookupRequest startAsynchronous];
		
	} else {
		[self.navigationController pushViewController:[[SNFriendProfileViewController_iPhone alloc] initWithTwitterUser:vo] animated:YES];
	}
}




#pragma mark - HTTPRequest Delegates
-(void)requestStarted:(ASIHTTPRequest *)request {
	//NSLog(@"requestStarted");
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
	//NSLog(@"didReceiveResponseHeaders:\n%@", responseHeaders);
}

-(void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
	NSLog(@"willRedirectToURL:\n%@", newURL);
}

-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"requestFinished:\n%@", [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding]);
	
	NSError *error = nil;
	
	if ([request isEqual:_idsRequest]) {
		NSDictionary *parsedUser = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *friendIDs = [NSMutableArray array];
			
			NSString *idList = @"";
            int cnt = 0;
			for (NSString *twitterID in [parsedUser objectForKey:@"ids"]) {
                if (cnt == 100)
                    break;
                
				idList = [idList stringByAppendingFormat:@",%@", twitterID];
				[friendIDs addObject:twitterID];
                cnt++;
			}
			
			_friendIDs = [friendIDs copy];
			
			_followingBlockRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/lookup.json?user_id=%@", [idList substringFromIndex:1]]]];
			_followingBlockRequest.delegate = self;
			[_followingBlockRequest startAsynchronous];
		}
		
	} else if ([request isEqual:_followingBlockRequest]) {
		NSArray *parsedFriends = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *friends = [NSMutableArray array];
			
			for (NSDictionary *dict in parsedFriends) {
				SNTwitterUserVO *vo = [SNTwitterUserVO twitterUserWithDictionary:dict];
				[friends addObject:vo];
			}
			
			_friends = [friends copy];
			[_tableView reloadData];
			
			_progressHUD.taskInProgress = NO;
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	
	} else if ([request isEqual:_friendLookupRequest]) {
		NSDictionary *parsedResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			if([[parsedResult objectForKey:@"result"] isEqualToString:@"true"])
				[self.navigationController pushViewController:[[SNFriendProfileViewController_iPhone alloc] initWithTwitterUser:(SNTwitterUserVO *)[_friends objectAtIndex:_selectedIndex]] animated:YES];
			
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invite Sent" message:[NSString stringWithFormat:@"Sent a tweet mentioning @%@", ((SNTwitterUserVO *)[_friends objectAtIndex:_selectedIndex]).handle] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
				[alert show];
				
				//[[SNTwitterCaller sharedInstance] sendTextTweet:[NSString stringWithFormat:kTweetInvite, ((SNTwitterUserVO *)[_friends objectAtIndex:_selectedIndex]).handle]];
			}
		}
		
	} else if ([request isEqual:_myFriendsRequest]) {
		NSArray *parsedFriends = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *friends = [NSMutableArray array];
			
			for (NSDictionary *dict in parsedFriends) {
				SNTwitterUserVO *vo = [SNTwitterUserVO twitterUserWithDictionary:dict];
				[friends addObject:vo];
			}
			
			_friends = [friends copy];
			[_tableView reloadData];
			
			_progressHUD.taskInProgress = NO;
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
	
	_progressHUD.graceTime = 0.0;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
	_progressHUD.labelText = NSLocalizedString(@"Error", @"Error");
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:1.5];
	_progressHUD = nil;
}

-(void)requestRedirected:(ASIHTTPRequest *)request {
	NSLog(@"requestRedirected");
}

@end
