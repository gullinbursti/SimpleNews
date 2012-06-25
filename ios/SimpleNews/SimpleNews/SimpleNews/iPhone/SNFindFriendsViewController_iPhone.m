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
#import "SNNavDoneBtnView.h"
#import "SNTwitterFriendViewCell_iPhone.h"
#import "SNTwitterUserVO.h"
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
		_sectionTitles = [NSArray arrayWithObjects:@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
		_friendsDictionary = [NSMutableDictionary dictionary];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_inviteFollower:) name:@"INVITE_FOLLOWER" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
	[self.view addSubview:bgImgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, self.view.frame.size.width, self.view.frame.size.height - 45.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];// colorWithPatternImage:[img stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0]]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 56.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.contentInset = UIEdgeInsetsMake(8.0, 0.0f, 8.0f, 0.0f);
	[self.view addSubview:_tableView];
	
	SNHeaderView_iPhone *headerView;
	
	if (_isFinder) {
		_tableView.contentInset = UIEdgeInsetsMake(10.0, 0.0f, 10.0f, 0.0f);
		
		headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Invite Friends"];
		[self.view addSubview:headerView];	
		
		_idsRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/followers/ids.json?id=%@", [SNAppDelegate twitterID]]]];
		_idsRequest.delegate = self;
		[_idsRequest startAsynchronous];
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		//_progressHUD.labelText = NSLocalizedString(@"Loading Following…", @"Status message when loading following list");
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
		//_progressHUD.labelText = NSLocalizedString(@"Loading Friends…", @"Status message when loading friend list");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
	}
	
	SNNavDoneBtnView *doneBtnView = [[SNNavDoneBtnView alloc] initWithFrame:CGRectMake(256.0, 0.0, 64.0, 44.0)];
	[[doneBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneBtnView];
	
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

#pragma mark Naviagation
-(void)_goBack {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Notification handlers
-(void)_inviteFollower:(NSNotification *)notification {
	_vo = (SNTwitterUserVO *)[notification object];
	
	_friendLookupRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]];
	[_friendLookupRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[_friendLookupRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[_friendLookupRequest setPostValue:_vo.twitterID forKey:@"twitterID"];
	[_friendLookupRequest setDelegate:self];
	[_friendLookupRequest startAsynchronous];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (_isFinder) {
		NSMutableArray *letterArray = [_friendsDictionary objectForKey:[_sectionTitles objectAtIndex:section]];
		return ([letterArray count]);
	
	} else
		return ([_friends count]);
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	int tot = 0;
	if (_isFinder) {
		for (NSArray *tmpArray in _friendsDictionary) {
			tot++;
		}
		
		return ([_sectionTitles count]);
	
	}else
		return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//static NSString * MyIdentifier = @"SNTwitterFriendViewCell_iPhone";
	
	//SNTwitterFriendViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNTwitterFriendViewCell_iPhone cellReuseIdentifier]];
	SNTwitterFriendViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	//NSMutableArray *letterArray = [_friendsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
	
	if (_isFinder) {
		if (cell == nil) {
			
			if ([_friends count] > 1) {
				if (indexPath.section == 0 && indexPath.row == 0) {
					cell = [[SNTwitterFriendViewCell_iPhone alloc] initAsHeader];
				
				} else if (indexPath.section == [tableView numberOfSections] - 1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
					cell = [[SNTwitterFriendViewCell_iPhone alloc] initAsFooter];
				
				} else {
					cell = [[SNTwitterFriendViewCell_iPhone alloc] initAsMiddle];
				}
			
			} else
				cell = [[SNTwitterFriendViewCell_iPhone alloc] initAsSolo];
		}
		
		NSMutableArray *letterArray = [_friendsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
		_vo = [letterArray objectAtIndex:indexPath.row];
		cell.twitterUserVO = _vo;
		
	} else {
		if (cell == nil) {
			if ([_friends count] > 1) {
				if (indexPath.row == 0) {
					cell = [[SNTwitterFriendViewCell_iPhone alloc] initAsHeader];
					
				} else if (indexPath.row == [_friends count] - 1) {
					cell = [[SNTwitterFriendViewCell_iPhone alloc] initAsFooter];
					
				} else {
					cell = [[SNTwitterFriendViewCell_iPhone alloc] initAsMiddle];
				}
				
			} else
				cell = [[SNTwitterFriendViewCell_iPhone alloc] initAsSolo];
		}
		
//		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 56.0, self.view.frame.size.width - 43.0, 1.0)];
//		[lineView setBackgroundColor:[SNAppDelegate snLineColor]];
//		[cell addSubview:lineView];
		
		cell.twitterUserVO = [_friends objectAtIndex:indexPath.row];
	}
	
	cell.isFinderCell = _isFinder;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	//NSLog(@"\nCELL FOR ROW:[(%d / %d) : (%d / %d]", indexPath.section, [tableView numberOfSections] - 1, indexPath.row, [tableView numberOfRowsInSection:indexPath.section] - 1);
	
	return (cell);
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return (_sectionTitles);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return (index);
}




#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (56.0);
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return (53.0);
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"WILL DISPLAY CELL:(%d, %d)", indexPath.section, indexPath.row);
	
	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 56.0, self.view.frame.size.width - 43.0, 1.0)];
	[lineView setBackgroundColor:[SNAppDelegate snLineColor]];
	//[cell addSubview:lineView];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (_isFinder)
		return (nil);
	
	else
		return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (_isFinder) {
		NSMutableArray *letterArray = [_friendsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
		_vo = [letterArray objectAtIndex:indexPath.row];
		
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			((SNTwitterFriendViewCell_iPhone *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
//			
//		} completion:^(BOOL finished) {
//			((SNTwitterFriendViewCell_iPhone *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
//		}];
		
		_friendLookupRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]];
		[_friendLookupRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[_friendLookupRequest setPostValue:_vo.twitterID forKey:@"twitterID"];
		[_friendLookupRequest setDelegate:self];
		[_friendLookupRequest startAsynchronous];
		
	} else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			((SNTwitterFriendViewCell_iPhone *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
			
		} completion:^(BOOL finished) {
			((SNTwitterFriendViewCell_iPhone *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
		}];
		
		[self.navigationController pushViewController:[[SNFriendProfileViewController_iPhone alloc] initWithTwitterUser:(SNTwitterUserVO *)[_friends objectAtIndex:indexPath.row]] animated:YES];
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
		NSArray *unsortedFriends = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		NSArray *parsedFriends = [NSMutableArray arrayWithArray:[unsortedFriends sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"screen_name" ascending:YES]]]];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *friends = [NSMutableArray array];
			
			for (NSDictionary *dict in parsedFriends) {
				SNTwitterUserVO *vo = [SNTwitterUserVO twitterUserWithDictionary:dict];
				[friends addObject:vo];
			}
			
			for (SNTwitterUserVO *vo in friends) {
				NSString *firstLetter = [[vo.handle substringToIndex:1] uppercaseString];
				
				if ([firstLetter isEqualToString:@"0"] || [firstLetter isEqualToString:@"1"] || [firstLetter isEqualToString:@"2"] || [firstLetter isEqualToString:@"3"] || [firstLetter isEqualToString:@"4"] || [firstLetter isEqualToString:@"5"] || [firstLetter isEqualToString:@"6"] || [firstLetter isEqualToString:@"7"] || [firstLetter isEqualToString:@"8"] || [firstLetter isEqualToString:@"9"])
					firstLetter = @"#";
				
				if ([_friendsDictionary objectForKey:firstLetter] == nil) {
					NSMutableArray * tmpArray = [NSMutableArray array];
					[tmpArray addObject:vo];
					[_friendsDictionary setObject:tmpArray forKey:firstLetter];
				
				} else {
					NSMutableArray *letterArray = [_friendsDictionary objectForKey:firstLetter];
					[letterArray addObject:vo];
					[_friendsDictionary setObject:letterArray forKey:firstLetter];
				}
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
				[self.navigationController pushViewController:[[SNFriendProfileViewController_iPhone alloc] initWithTwitterUser:_vo] animated:YES];
			
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" 
																				message:@"A tweet has been sent to your friend about Assembly." 
																			  delegate:nil 
																  cancelButtonTitle:@"OK" 
																  otherButtonTitles:nil];
				[alert show];
				
				if (kLiveTweet)
					[[SNTwitterCaller sharedInstance] sendTextTweet:[NSString stringWithFormat:kTweetInvite, _vo.handle]];
				
				else
					NSLog(@"TWEET MENTIONING TURNED OFF!");
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
