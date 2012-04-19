//
//  SNOptionsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "SNOptionsViewController_iPhone.h"

#import "SNOptionViewCell_iPhone.h"
#import "SNOptionVO.h"

#import "SNAppDelegate.h"

#import "SNHeaderView_iPhone.h"
#import "SNWebPageViewController_iPhone.h"

@implementation SNOptionsViewController_iPhone

-(id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {	
	[super dealloc];
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	_optionViews = [[NSMutableArray alloc] init];
	_optionVOs = [[NSMutableArray alloc] init];
	
	SNHeaderView_iPhone *headerView = [[[SNHeaderView_iPhone alloc] initWithTitle:@"settings"] autorelease];
	[self.view addSubview:headerView];
	
	UIButton *doneButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	doneButton.frame = CGRectMake(250.0, 3.0, 64.0, 48.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive.png"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active.png"] forState:UIControlStateHighlighted];
	doneButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11.0];
	doneButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[doneButton setTitle:@"Done" forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 53.0, self.view.frame.size.width, self.view.frame.size.height - 53.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.rowHeight = 74.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_tableView];
		
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	NSString *testOptionsPath = [[NSBundle mainBundle] pathForResource:@"options" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testOptionsPath] options:NSPropertyListImmutable format:nil error:nil];
	
	for (NSDictionary *testOption in plist)
		[_optionVOs addObject:[SNOptionVO optionWithDictionary:testOption]];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}



#pragma mark - Navigation
-(void)_goDone {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"OPTIONS_RETURN" object:nil];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)_goNotificationsToggle:(UISwitch *)switchView {
	
	//UITableViewCell *cell = (UITableViewCell *)[switchView superview];
	//UITableView *table = (UITableView *)[cell superview];
	//NSIndexPath *switchViewIndexPath = [table indexPathForCell:cell];
	
	[SNAppDelegate notificationsToggle:switchView.on];
}

-(void)_goTwitterToggle:(UISwitch *)switchView {
	
	//UITableViewCell *cell = (UITableViewCell *)[switchView superview];
	//UITableView *table = (UITableView *)[cell superview];
	//NSIndexPath *switchViewIndexPath = [table indexPathForCell:cell];
	
	//[SNAppDelegate notificationsToggle:switchView.on];
}



#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_optionVOs count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNOptionViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNOptionViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[[SNOptionViewCell_iPhone alloc] init] autorelease];
	
	cell.optionVO = (SNOptionVO *)[_optionVOs objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

	if (indexPath.row == 0 || indexPath.row == 1) {
		UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
		switchView.on = YES;
		cell.accessoryView = switchView;
		
		if (indexPath.row == 0) {
			switchView.on = [SNAppDelegate notificationsEnabled];
			[switchView addTarget:self action:@selector(_goNotificationsToggle:) forControlEvents:UIControlEventValueChanged];
		
		} else if (indexPath.row == 1) {
			if (![SNAppDelegate twitterHandle])
				switchView.on = NO;
			
			[switchView addTarget:self action:@selector(_goTwitterToggle:) forControlEvents:UIControlEventValueChanged];
		}
		
		[switchView release];
	
	} else {
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0, 23.0, 24, 24)];		
		chevronView.image = [UIImage imageNamed:@"chevron.png"];
		[cell addSubview:chevronView];
		[chevronView release];
	}
	
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (74.0);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0 || indexPath.row == 1)
		return (nil);
	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	NSLog(@"SELECTED");
	
	if (indexPath.row == 2 || indexPath.row == 3) {
		SNOptionVO *vo = (SNOptionVO *)[_optionVOs objectAtIndex:indexPath.row];
		SNWebPageViewController_iPhone *optionsPageViewController = [[[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:vo.option_url] title:vo.option_title] autorelease];
		[self.navigationController setNavigationBarHidden:YES];
		[self.navigationController pushViewController:optionsPageViewController animated:YES];
	}
}

@end
