//
//  SNProfileFollowingListsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileFollowingListsViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNListVO.h"
#import "SNProfileFollowingListViewCell_iPhone.h"
#import "SNArticleListViewController_iPhone.h"

@implementation SNProfileFollowingListsViewController_iPhone

- (id)init {
	if ((self = [super init])) {
		_lists = [NSMutableArray new];
		
		_listsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[_listsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_listsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_listsRequest setDelegate:self];
		[_listsRequest startAsynchronous];
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
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Following Topics"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
}

- (void)viewDidUnload {
	_progressHUD = nil;
	
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_lists count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNProfileFollowingListViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNProfileFollowingListViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNProfileFollowingListViewCell_iPhone alloc] init];
	
	cell.listVO = (SNListVO *)[_lists objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;	
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete)
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade]; 
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	[self.navigationController pushViewController:[[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[_lists objectAtIndex:indexPath.row]] animated:YES];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNProfileFollowingListsViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		NSArray *parsedLists = [unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNListVO *vo = [SNListVO listWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\"", vo.list_name);
				
				if (vo != nil)
					[list addObject:vo];
			}
			
			_lists = [list copy];
			[_tableView reloadData];
		}
	}
	
	[_progressHUD hide:YES];
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
