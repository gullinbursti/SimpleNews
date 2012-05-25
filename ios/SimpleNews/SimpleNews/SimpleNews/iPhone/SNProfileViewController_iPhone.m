//
//  SNProfileViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileViewController_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNProfileHeaderViewCell_iPhone.h"
#import "SNProfileViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "EGOImageView.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNProfileArticlesViewController_iPhone.h"
#import "SNProfileFollowingListsViewController_iPhone.h"
#import "SNFindFriendsViewController_iPhone.h"

@implementation SNProfileViewController_iPhone
-(id)init {
	if ((self = [super init])) {
		_items = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
	}
	
	return (self);
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.contentInset = UIEdgeInsetsMake(-17.0f, 0.0f, 0.0f, 0.0f);
	[self.view addSubview:_tableView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Profile"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	NSString *profilePath = [[NSBundle mainBundle] pathForResource:@"profile" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:profilePath] options:NSPropertyListImmutable format:nil error:nil];
	
	for (NSDictionary *item in plist)
		[_items addObject:[SNProfileVO profileWithDictionary:item]];
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

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", [SNAppDelegate twitterHandle]]] title:[NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goNotificationsToggle:(UISwitch *)switchView {
	[SNAppDelegate notificationsToggle:switchView.on];
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_items count] + 1);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNProfileViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNProfileViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNProfileViewCell_iPhone alloc] initAsHeaderCell:(indexPath.row == 0)];
	
	if (indexPath.row > 0) {
		cell.profileVO = (SNProfileVO *)[_items objectAtIndex:indexPath.row - 1];
		
		NSLog(@"PROFILE VO:\n%@", cell.profileVO.title);
	
		if (indexPath.row - 1 == [_items count] - 1) {
			UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
			
			if ([SNAppDelegate notificationsEnabled])
				switchView.on = YES;
			
			[switchView addTarget:self action:@selector(_goNotificationsToggle:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = switchView;
			
		} else {
			UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(284.0, 23.0, 24, 24)];		
			chevronView.image = [UIImage imageNamed:@"chevron_nonActive.png"];
			[cell addSubview:chevronView];
		}
	}
	
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
	if (indexPath.row == [_items count])
		return (nil);
	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"SELECTED");
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	switch (indexPath.row) {
		case 0: // profile
			break;
			
		case 1: // liked
			[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesLiked] animated:YES];
			break;
			
		case 2: // read
			[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesRead] animated:YES];
			break;
			
		case 3: // following
			[self.navigationController pushViewController:[[SNProfileFollowingListsViewController_iPhone alloc] init] animated:YES];
			break;
			
		case 4: // friends
			[self.navigationController pushViewController:[[SNFindFriendsViewController_iPhone alloc] initAsFinder] animated:YES];
			break;
			
		case 5: // friends
			[self.navigationController pushViewController:[[SNFindFriendsViewController_iPhone alloc] initAsList] animated:YES];
			break;
			
		default:
			break;
	}
}


@end
