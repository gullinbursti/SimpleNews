//
//  SNFriendProfileViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.25.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFriendProfileViewController_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNProfileViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNProfileArticlesViewController_iPhone.h"
#import "SNFindFriendsViewController_iPhone.h"
#import "SNTwitterAvatarView.h"
#import "ASIFormDataRequest.h"

@implementation SNFriendProfileViewController_iPhone

- (id)initWithTwitterUser:(SNTwitterUserVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
		_items = [NSMutableArray new];
		_switches = [NSMutableArray new];
	}
	
	return (self);
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
	[self.view addSubview:bgImgView];
	
	SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(20.0, 68.0) imageURL:_vo.avatarURL handle:_vo.handle];
	//[[avatarImgView btn] addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:avatarImgView];
	
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 72.0, 200.0, 16.0)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	handleLabel.textColor = [SNAppDelegate snLinkColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@", _vo.handle];
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
	
	UIImageView *statsBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 108.0, 320.0, 84.0)];
	statsBgView.image = [UIImage imageNamed:@"profileBackgroundStats.png"];
	[self.view addSubview:statsBgView];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 23.0, 96.0, 18.0)];
	_commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18];
	_commentsLabel.textAlignment = UITextAlignmentCenter;
	_commentsLabel.textColor = [UIColor blackColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_commentsLabel];
	
	UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 43.0, 96.0, 18.0)];
	commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	commentsLabel.textAlignment = UITextAlignmentCenter;
	commentsLabel.textColor = [SNAppDelegate snLinkColor];
	commentsLabel.backgroundColor = [UIColor clearColor];
	commentsLabel.text = @"Comments";
	[statsBgView addSubview:commentsLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(111.0, 23.0, 96.0, 18.0)];
	_likesLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18];
	_likesLabel.textAlignment = UITextAlignmentCenter;
	_likesLabel.textColor = [UIColor blackColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_likesLabel];
	
	UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(111.0, 43.0, 96.0, 18.0)];
	likesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	likesLabel.textAlignment = UITextAlignmentCenter;
	likesLabel.textColor = [SNAppDelegate snLinkColor];
	likesLabel.backgroundColor = [UIColor clearColor];
	likesLabel.text = @"Likes";
	[statsBgView addSubview:likesLabel];
	
	_sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0, 23.0, 96.0, 18.0)];
	_sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18];
	_sharesLabel.textAlignment = UITextAlignmentCenter;
	_sharesLabel.textColor = [UIColor blackColor];
	_sharesLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_sharesLabel];
	
	UILabel *sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0, 43.0, 96.0, 18.0)];
	sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	sharesLabel.textAlignment = UITextAlignmentCenter;
	sharesLabel.textColor = [SNAppDelegate snLinkColor];
	sharesLabel.backgroundColor = [UIColor clearColor];
	sharesLabel.text = @"Shares";
	[statsBgView addSubview:sharesLabel];
	
//	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	likeButton.frame = CGRectMake(108.0, 115.0, 96.0, 70.0);
//	[likeButton addTarget:self action:@selector(_goLikedArticles) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:likeButton];
//	
//	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	commentButton.frame = CGRectMake(12.0, 115.0, 96.0, 70.0);
//	[commentButton addTarget:self action:@selector(_goCommentedArticles) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:commentButton];
//	
//	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	shareButton.frame = CGRectMake(204.0, 115.0, 96.0, 70.0);
//	[shareButton addTarget:self action:@selector(_goSharedArticles) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:shareButton];
	
	UIImageView *tableBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 186.0, 320.0, self.view.frame.size.height - 267.0)];
	UIImage *img = [UIImage imageNamed:@"profileBackground.png"];
	tableBgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
	[self.view addSubview:tableBgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(12.0, 195.0, self.view.frame.size.width - 24.0, self.view.frame.size.height - 277.0) style:UITableViewStylePlain];
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
	
	UIView *line2View = [[UIView alloc] initWithFrame:CGRectMake(12.0, 319.0, 296.0, 1.0)];
	[line2View setBackgroundColor:[SNAppDelegate snLineColor]];
	[self.view addSubview:line2View];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Profile"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	NSString *profilePath = [[NSBundle mainBundle] pathForResource:@"friend_profile" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:profilePath] options:NSPropertyListImmutable format:nil error:nil];
	
	for (NSDictionary *item in plist)
		[_items addObject:[SNProfileVO profileWithDictionary:item]];
	
	_commentSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	[_commentSwitch addTarget:self action:@selector(_goCommentSwitch:) forControlEvents:UIControlEventValueChanged];
	
	_likeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	[_likeSwitch addTarget:self action:@selector(_goLikeSwitch:) forControlEvents:UIControlEventValueChanged];
	
	_shareSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	[_shareSwitch addTarget:self action:@selector(_goShareSwitch:) forControlEvents:UIControlEventValueChanged];
	
	ASIFormDataRequest *statsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users2.php"]]];
	[statsRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
	[statsRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.userID] forKey:@"userID"];
	[statsRequest setDelegate:self];
	[statsRequest startAsynchronous];
	
	_notificationsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users2.php"]]];
	[_notificationsRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[_notificationsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[_notificationsRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.userID] forKey:@"friendID"];
	[_notificationsRequest setDelegate:self];
	[_notificationsRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goTwitterProfile {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", _vo.handle]] title:[NSString stringWithFormat:@"@%@", _vo.handle]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goCommentSwitch:(UISwitch *)switchView {
	NSString *msg;
	
	if (switchView.on)
		msg = @"Turn on notifications from @%@?";
	
	else
		msg = @"Turn off notifications from @%@?";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Comments" 
													message:[NSString stringWithFormat:msg, _vo.handle]
												   delegate:self 
										  cancelButtonTitle:@"Yes" 
										  otherButtonTitles:@"No", nil];
	[alert show];	
	_switch = switchView;
}

-(void)_goLikeSwitch:(UISwitch *)switchView {
	NSString *msg;
	
	if (switchView.on)
		msg = @"Turn on notifications from @%@?";
	
	else
		msg = @"Turn off notifications from @%@?";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Likes" 
													message:[NSString stringWithFormat:msg, _vo.handle] 
												   delegate:self 
										  cancelButtonTitle:@"Yes" 
										  otherButtonTitles:@"No", nil];
	[alert show];
	_switch = switchView;
}

-(void)_goShareSwitch:(UISwitch *)switchView {
	NSString *msg;
	
	if (switchView.on)
		msg = @"Turn on notifications from @%@?";
	
	else
		msg = @"Turn off notifications from @%@?";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Shares" 
													message:[NSString stringWithFormat:msg, _vo.handle] 
												   delegate:self 
										  cancelButtonTitle:@"Yes" 
										  otherButtonTitles:@"No", nil];
	[alert show];
	_switch = switchView;
}

-(void)_goLikedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initWithUserID:_vo.userID asType:6] animated:YES];
}

-(void)_goCommentedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initWithUserID:_vo.userID asType:2] animated:YES];
}

-(void)_goSharedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initWithUserID:_vo.userID asType:5] animated:YES];
}


#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			_notificationsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users2.php"]]];
			[_notificationsRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
			[_notificationsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
			[_notificationsRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.userID] forKey:@"friendID"];
			[_notificationsRequest setPostValue:[NSString stringWithFormat:@"%d", _commentSwitch.on] forKey:@"isComment"];
			[_notificationsRequest setPostValue:[NSString stringWithFormat:@"%d", _likeSwitch.on] forKey:@"isLike"];
			[_notificationsRequest setPostValue:[NSString stringWithFormat:@"%d", _shareSwitch.on] forKey:@"isShare"];
			[_notificationsRequest setDelegate:self];
			[_notificationsRequest startAsynchronous];
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
	SNProfileViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNProfileViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNProfileViewCell_iPhone alloc] init];
	
	cell.profileVO = (SNProfileVO *)[_items objectAtIndex:indexPath.row];
	
	switch (indexPath.row) {
		case 0:
			cell.accessoryView = _commentSwitch;
			break;
			
		case 1:
			cell.accessoryView = _likeSwitch;
			break;
			
		case 2:
			cell.accessoryView = _shareSwitch;
			break;
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (64.0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNFriendProfileViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:_notificationsRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSDictionary *parsedNotifications = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				_commentSwitch.on = (BOOL)[[parsedNotifications objectForKey:@"comment"] intValue];
				_likeSwitch.on = (BOOL)[[parsedNotifications objectForKey:@"like"] intValue];
				_shareSwitch.on = (BOOL)[[parsedNotifications objectForKey:@"share"] intValue];
			}
		}
	
	} else {
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
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
