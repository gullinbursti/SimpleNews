//
//  SNProfileViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

//#import <FBiOSSDK/FacebookSDK.h>
#import <FacebookSDK/FacebookSDK.h>

#import "SNProfileViewController.h"

#import "SNHeaderView.h"
#import "SNNavDoneBtnView.h"
#import "SNProfileViewCell.h"
#import "SNAppDelegate.h"
#import "SNTwitterAvatarView.h"
#import "SNWebPageViewController.h"
#import "SNProfileArticlesViewController.h"
#import "SNFindFriendsViewController.h"

@implementation SNProfileViewController
-(id)init {
	if ((self = [super init])) {
		_items = [NSMutableArray new];
		_switches = [NSArray arrayWithObjects:
						 [[UISwitch alloc] initWithFrame:CGRectZero], 
						 [[UISwitch alloc] initWithFrame:CGRectZero], 
						 [[UISwitch alloc] initWithFrame:CGRectZero], nil];
	}
	
	return (self);
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
	[self.view addSubview:bgImgView];
	
	EGOImageView *avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 68.0, 26.0, 26.0)];
	avatarImgView.imageURL = [NSURL URLWithString:[SNAppDelegate twitterAvatar]];
	[self.view addSubview:avatarImgView];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = avatarImgView.frame;
	[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:avatarButton];

	
//	SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(20.0, 68.0) imageURL:[SNAppDelegate twitterAvatar] handle:[SNAppDelegate twitterHandle]];
//	[[avatarImgView btn] addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:avatarImgView];
	
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 72.0, 200.0, 16.0)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	handleLabel.textColor = [SNAppDelegate snLinkColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]];
	[self.view addSubview:handleLabel];
	
	UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	handleButton.frame = handleLabel.frame;
	[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:handleButton];
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(266.0, 59.0, 44.0, 44.0);
	[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
	[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
	[profileButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:profileButton];
	
	// Create Login View so that the app will be granted "status_update" permission.
	FBLoginView *loginview = [[FBLoginView alloc] initWithPermissions:[SNAppDelegate fbPermissions]];
	
	loginview.frame = CGRectOffset(loginview.frame, 130.0, 65.0);
	[self.view addSubview:loginview];
	
	UIImageView *statsBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 108.0, 320.0, 84.0)];
	statsBgView.image = [UIImage imageNamed:@"profileBackgroundStats.png"];
	statsBgView.clipsToBounds = YES;
	[self.view addSubview:statsBgView];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 23.0, 97.0, 18.0)];
	_commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18];
	_commentsLabel.textAlignment = UITextAlignmentCenter;
	_commentsLabel.textColor = [UIColor blackColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_commentsLabel];
	
	UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 43.0, 97.0, 18.0)];
	commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	commentsLabel.textAlignment = UITextAlignmentCenter;
	commentsLabel.textColor = [SNAppDelegate snLinkColor];
	commentsLabel.backgroundColor = [UIColor clearColor];
	commentsLabel.text = @"Comments";
	[statsBgView addSubview:commentsLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 23.0, 100.0, 18.0)];
	_likesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18];
	_likesLabel.textAlignment = UITextAlignmentCenter;
	_likesLabel.textColor = [UIColor blackColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_likesLabel];
	
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
	[statsBgView addSubview:_sharesLabel];
	
	UILabel *sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 43.0, 97.0, 18.0)];
	sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	sharesLabel.textAlignment = UITextAlignmentCenter;
	sharesLabel.textColor = [SNAppDelegate snLinkColor];
	sharesLabel.backgroundColor = [UIColor clearColor];
	sharesLabel.text = @"Shares";
	[statsBgView addSubview:sharesLabel];
	
//	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	commentButton.frame = CGRectMake(12.0, 115.0, 97.0, 68.0);
//	[commentButton addTarget:self action:@selector(_goCommentedArticles:) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:commentButton];
//	 
//	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	likeButton.frame = CGRectMake(110.0, 115.0, 100.0, 68.0);
//	[likeButton addTarget:self action:@selector(_goLikedArticles:) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:likeButton];
//	
//	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	shareButton.frame = CGRectMake(210.0, 115.0, 97.0, 68.0);
//	[shareButton addTarget:self action:@selector(_goSharedArticles:) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:shareButton];
	
	UIImageView *tableBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 187.0, 320.0, self.view.frame.size.height - 267.0)];
	UIImage *img = [UIImage imageNamed:@"profileBackground.png"];
	tableBgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
	[self.view addSubview:tableBgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(12.0, 196.0, self.view.frame.size.width - 24.0, self.view.frame.size.height - 277.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 64.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.alwaysBounceVertical = NO;
	_tableView.bounces = NO;
	[self.view addSubview:_tableView];
	
	UIView *line1View = [[UIView alloc] initWithFrame:CGRectMake(12.0, 259.0, 296.0, 1.0)];
	[line1View setBackgroundColor:[SNAppDelegate snLineColor]];
	[self.view addSubview:line1View];
	
	UIView *line2View = [[UIView alloc] initWithFrame:CGRectMake(12.0, 323.0, 296.0, 1.0)];
	[line2View setBackgroundColor:[SNAppDelegate snLineColor]];
	[self.view addSubview:line2View];
	
	
	UIImageView *privacyBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 397.0, 320.0, 74.0)];
	privacyBgView.image = [UIImage imageNamed:@"privacyPolicy_nonActive.png"];
	privacyBgView.userInteractionEnabled = YES;
	privacyBgView.clipsToBounds = YES;
	[self.view addSubview:privacyBgView];
	
	UILabel *privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(29.0, 27.0, 256.0, 18.0)];
	privacyLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	privacyLabel.textColor = [UIColor blackColor];
	privacyLabel.backgroundColor = [UIColor clearColor];
	privacyLabel.text = @"Privacy Policy";
	[privacyBgView addSubview:privacyLabel];
	
	UIButton *privacyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	privacyButton.frame = CGRectMake(12.0, 398.0, 296.0, 67.0);
	[privacyButton addTarget:self action:@selector(_goPrivacy:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:privacyButton];
	
	UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(277.0, 23.0, 24.0, 24.0)];
	chevronView.image = [UIImage imageNamed:@"chevron.png"];
	[privacyBgView addSubview:chevronView];
	
	SNHeaderView *headerView = [[SNHeaderView alloc] initWithTitle:@"Profile"];
	[self.view addSubview:headerView];
	
	SNNavDoneBtnView *doneBtnView = [[SNNavDoneBtnView alloc] initWithFrame:CGRectMake(256.0, 0.0, 64.0, 44.0)];
	[[doneBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneBtnView];
	
	NSString *profilePath = [[NSBundle mainBundle] pathForResource:@"user_profile" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:profilePath] options:NSPropertyListImmutable format:nil error:nil];
	
	for (NSDictionary *item in plist)
		[_items addObject:[SNProfileVO profileWithDictionary:item]];
	
	ASIFormDataRequest *statsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kUsersAPI]]];
	[statsRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
	[statsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[statsRequest setDelegate:self];
	[statsRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)_goTwitterProfile {
	SNWebPageViewController *webPageViewController = [[SNWebPageViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", [SNAppDelegate twitterHandle]]] title:[NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goNotificationsToggle:(UISwitch *)switchView {
//	NSString *msg;
	
	for (UISwitch *switchV in _switches) {
		switchV.on = switchView.on;
	}
	
	_switch = switchView;
	
	[SNAppDelegate notificationsToggle:switchView.on];
	
//	if (switchView.on)
//		msg = @"Turn on notifications?";
//	
//	else
//		msg = @"Turn off notifications?";
//	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications" 
//																	message:msg 
//																  delegate:self 
//													  cancelButtonTitle:@"Yes" 
//													  otherButtonTitles:@"No", nil];
//	[alert show];
}


-(void)_goCommentedArticles:(UIButton *)button {
	[button setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.25]];
	[UIView animateWithDuration:0.15 animations:^(void) {
		[button setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	}];
	
	[self.navigationController pushViewController:[[SNProfileArticlesViewController alloc] initWithUserID:[[[SNAppDelegate profileForUser] objectForKey:@"id"] intValue] asType:2] animated:YES];
}

-(void)_goLikedArticles:(UIButton *)button {
	[button setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.25]];
	[UIView animateWithDuration:0.15 animations:^(void) {
		[button setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	}];

	[self.navigationController pushViewController:[[SNProfileArticlesViewController alloc] initWithUserID:[[[SNAppDelegate profileForUser] objectForKey:@"id"] intValue] asType:6] animated:YES];
}

-(void)_goSharedArticles:(UIButton *)button {
	[button setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.25]];
	[UIView animateWithDuration:0.15 animations:^(void) {
		[button setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	}];

	[self.navigationController pushViewController:[[SNProfileArticlesViewController alloc] initWithUserID:[[[SNAppDelegate profileForUser] objectForKey:@"id"] intValue] asType:5] animated:YES];
}

- (void)_goPrivacy:(UIButton *)button {
	[button setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.25]];
	[UIView animateWithDuration:0.15 animations:^(void) {
		[button setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	}];
	
	SNWebPageViewController *webPageViewController = [[SNWebPageViewController alloc] initWithURL:[NSURL URLWithString:kPrivacyPage] title:@"Privacy Policy"];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}


#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			[SNAppDelegate notificationsToggle:_switch.on];
			break;
			
		case 1:
			_switch.on = !_switch.on;
			break;
	}
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_items count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNProfileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SNProfileViewCell cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNProfileViewCell alloc] init];
	
	cell.profileVO = (SNProfileVO *)[_items objectAtIndex:indexPath.row];
	
//	if (indexPath.row == 2) {
		_switch = [_switches objectAtIndex:indexPath.row];
			
		if ([SNAppDelegate notificationsEnabled])
			_switch.on = YES;
			
		[_switch addTarget:self action:@selector(_goNotificationsToggle:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = _switch;
			
//	} else {
//		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(265.0, 23.0, 24.0, 24.0)];
//		chevronView.image = [UIImage imageNamed:@"chevron.png"];
//		[cell addSubview:chevronView];
//	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (64.0);
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return (53.0);
//}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//if (indexPath.row == 2)
		return (nil);
	
	//return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		((SNProfileViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
	
	} completion:^(BOOL finished) {
		((SNProfileViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
	}];
	
	
	switch (indexPath.row) {
		case 0: // find friends
			[self.navigationController pushViewController:[[SNFindFriendsViewController alloc] initAsFinder] animated:YES];
			break;
			
		case 1: // my friends
			[self.navigationController pushViewController:[[SNFindFriendsViewController alloc] initAsList] animated:YES];
			break;
			
		default:
			break;
	}
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
