//
//  SNProfileArticlesViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileArticlesViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNProfileArticleViewCell_iPhone.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNWebPageViewController_iPhone.h"

@implementation SNProfileArticlesViewController_iPhone

- (id)initWithUserID:(int)userID asType:(int)type {
	if ((self = [super init])) {

		switch (type) {
			case 6:
				_headerTitle = @"Likes";
				break;
				
			case 2:
				_headerTitle = @"Comments";
				break;
				
			case 5:
				_headerTitle = @"Shares";
				break;
		}
		
		
		_articlesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", type] forKey:@"action"];
		[_articlesRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
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
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_headerTitle];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
}

-(void)viewDidUnload {
	_progressHUD = nil;
	
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_articles count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	SNProfileArticleViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNProfileArticleViewCell_iPhone cellReuseIdentifier]];
		
	if (cell == nil)
		cell = [[SNProfileArticleViewCell_iPhone alloc] init];
		
	cell.articleVO = (SNArticleVO *)[_articles objectAtIndex:indexPath.row];
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
	
	SNArticleVO *vo = (SNArticleVO *)[_articles objectAtIndex:indexPath.row];	
	[self.navigationController pushViewController:[[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:vo.article_url] title:vo.title] animated:YES];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNProfileArticlesViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"ARTICLE \"@%@\"", vo.title);
					
				if (vo != nil)
					[list addObject:vo];
			}
				
			_articles = [list copy];
			[_tableView reloadData];
		}
	}
	
	[_progressHUD hide:YES];
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
