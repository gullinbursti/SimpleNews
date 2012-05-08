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
#import "SNOptionViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "EGOImageView.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNProfileArticlesViewController_iPhone.h"

@implementation SNProfileViewController_iPhone
-(id)init {
	if ((self = [super init])) {
		_items = [NSMutableArray new];
	}
	
	return (self);
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Profile"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	EGOImageView *avatarImg = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 70.0, 25.0, 25.0)];
	avatarImg.imageURL = [NSURL URLWithString:[SNAppDelegate twitterAvatar]];
	[self.view addSubview:avatarImg];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = avatarImg.frame;
	[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:avatarButton];
	
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 75.0, 200.0, 16.0)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	handleLabel.textColor = [SNAppDelegate snLinkColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]];
	[self.view addSubview:handleLabel];
	
	UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	handleButton.frame = handleLabel.frame;
	[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:handleButton];
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(273.0, 65.0, 34.0, 34.0);
	[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
	[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
	[profileButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:profileButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 100.0, self.view.frame.size.width, self.view.frame.size.height - 100.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.rowHeight = 74.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	
	NSString *testOptionsPath = [[NSBundle mainBundle] pathForResource:@"options" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testOptionsPath] options:NSPropertyListImmutable format:nil error:nil];
	
	for (NSDictionary *testOption in plist)
		[_items addObject:[SNOptionVO optionWithDictionary:testOption]];
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
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", [SNAppDelegate twitterHandle]]] title:[NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]]];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goNotificationsToggle:(UISwitch *)switchView {
	[SNAppDelegate notificationsToggle:switchView.on];
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_items count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNOptionViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNOptionViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNOptionViewCell_iPhone alloc] init];
	
	cell.optionVO = (SNOptionVO *)[_items objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	if (indexPath.row == [_items count] - 1) {
		UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
		
		if ([SNAppDelegate notificationsEnabled])
			switchView.on = YES;
		
		[switchView addTarget:self action:@selector(_goNotificationsToggle:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = switchView;
		
	} else {
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0, 23.0, 24, 24)];		
		chevronView.image = [UIImage imageNamed:@"chevron_nonActive.png"];
		[cell addSubview:chevronView];
	}
	
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (74.0);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == [_items count] - 1)
		return (nil);
	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"SELECTED");
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	switch (indexPath.row) {
		case 0:
			break;
			
		case 1: // read
			[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesRead] animated:YES];
			break;
			
		case 2: // liked
			[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesLiked] animated:YES];
			break;
			
		case 3: // following
			break;
			
		default:
			break;
	}
	
}




@end
