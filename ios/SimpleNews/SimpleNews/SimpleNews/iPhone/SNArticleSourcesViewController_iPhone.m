//
//  SNArticleSourcesViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleSourcesViewController_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNArticleSourceViewCell_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNArticleSourceVO.h"

@implementation SNArticleSourcesViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_sources = [NSMutableArray new];
	}
	
	return (self);
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Popular Filters"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 49.0, self.view.frame.size.width, self.view.frame.size.height - 49.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 78.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	//_tableView.allowsSelection = NO;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_tableView];
		
	NSString *sourcesPath = [[NSBundle mainBundle] pathForResource:@"sources" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:sourcesPath] options:NSPropertyListImmutable format:nil error:nil];
	
	for (NSDictionary *source in plist)
		[_sources addObject:[SNArticleSourceVO sourceWithDictionary:source]];
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


-(void)_goSourceToggle:(UISwitch *)switchView {
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_sources count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNArticleSourceViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNArticleSourceViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNArticleSourceViewCell_iPhone alloc] init];
	
	UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(223.0, 21.0, 100.0, 50.0)];
	[switchView addTarget:self action:@selector(_goSourceToggle:) forControlEvents:UIControlEventValueChanged];
	switchView.on = YES;
	[cell addSubview:switchView];
		
	cell.sourceVO = (SNArticleSourceVO *)[_sources objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (78.0);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

@end
