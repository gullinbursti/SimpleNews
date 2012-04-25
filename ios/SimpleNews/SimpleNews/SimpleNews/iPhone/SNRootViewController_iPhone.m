//
//  SNRootViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNRootViewController_iPhone.h"
#import "SNListVO.h"
#import "SNOptionVO.h"

#import "SNSubscribedListsViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNArticleListViewController_iPhone.h"
#import "SNRootListViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNOptionsViewController_iPhone.h"
#import "SNArticleListViewController_iPhone.h"

@interface SNRootViewController_iPhone()
-(void)_goSubscribedLists;
-(void)_goListsToggle;
@end

@implementation SNRootViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_subscribedLists = [NSMutableArray new];
		_popularLists = [NSMutableArray new];
		
		_isIntro = YES;
		_isFollowingList = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSubscribedList:) name:@"REFRESH_SUBSCRIBED_LIST" object:nil];
		
		_subscribedListsRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
		[_subscribedListsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_subscribedListsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_subscribedListsRequest setDelegate:self];
		
		_popularListsRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
		[_popularListsRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
		
		if ([[SNAppDelegate profileForUser] objectForKey:@"id"])
			[_popularListsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		
		else
			[_popularListsRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"userID"];
		
		[_popularListsRequest setDelegate:self];
		[_popularListsRequest startAsynchronous];	
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *logoImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(118, 198, 84.0, 84.0)] autorelease];
	logoImgView.image = [UIImage imageNamed:@"logo_01.png"];
	[self.view addSubview:logoImgView];
	
	SNHeaderView_iPhone *headerView = [[[SNHeaderView_iPhone alloc] init] autorelease];
	[self.view addSubview:headerView];
	
	UIButton *optionsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	optionsButton.frame = CGRectMake(4.0, 4.0, 44.0, 44.0);
	[optionsButton setBackgroundImage:[UIImage imageNamed:@"optionsButton_nonActive.png"] forState:UIControlStateNormal];
	[optionsButton setBackgroundImage:[UIImage imageNamed:@"optionsButton_Active.png"] forState:UIControlStateHighlighted];
	[optionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:optionsButton];
	
	_toggleLtImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(78.0, 4.0, 164.0, 44.0)] autorelease];
	_toggleLtImgView.image = [UIImage imageNamed:@"toggleBGLeft.png"];
	[self.view addSubview:_toggleLtImgView];
	
	UILabel *followingOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 14.0, 100.0, 16.0)];
	followingOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	followingOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	followingOnLabel.backgroundColor = [UIColor clearColor];
	followingOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	followingOnLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	followingOnLabel.text = @"Following";
	[_toggleLtImgView addSubview:followingOnLabel];
	
	UILabel *popularOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 14.0, 100.0, 16.0)];
	popularOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	popularOffLabel.textColor = [UIColor blackColor];
	popularOffLabel.backgroundColor = [UIColor clearColor];
	popularOffLabel.text = @"Popular";
	[_toggleLtImgView addSubview:popularOffLabel];
	
	_toggleRtImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(78.0, 4.0, 164.0, 44.0)] autorelease];
	_toggleRtImgView.image = [UIImage imageNamed:@"toggleBGRight.png"];
	_toggleRtImgView.hidden = YES;
	[self.view addSubview:_toggleRtImgView];
	
	UILabel *followingOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 14.0, 100.0, 16.0)];
	followingOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	followingOffLabel.textColor = [UIColor blackColor];
	followingOffLabel.backgroundColor = [UIColor clearColor];
	followingOffLabel.text = @"Following";
	[_toggleRtImgView addSubview:followingOffLabel];
	
	UILabel *popularOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 14.0, 100.0, 16.0)];
	popularOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	popularOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	popularOnLabel.backgroundColor = [UIColor clearColor];
	popularOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	popularOnLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	popularOnLabel.text = @"Popular";
	[_toggleRtImgView addSubview:popularOnLabel];
	
	UIButton *toggleButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	toggleButton.frame = CGRectMake(78.0, 4.0, 164.0, 44.0);
	[toggleButton addTarget:self action:@selector(_goListsToggle) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:toggleButton];
		
	UIButton *subscribedButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	subscribedButton.frame = CGRectMake(272.0, 4.0, 44.0, 44.0);
	[subscribedButton setBackgroundImage:[UIImage imageNamed:@"rightArrowButton_nonActive.png"] forState:UIControlStateNormal];
	[subscribedButton setBackgroundImage:[UIImage imageNamed:@"rightArrowButton_Active.png"] forState:UIControlStateHighlighted];
	[subscribedButton addTarget:self action:@selector(_goSubscribedLists) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:subscribedButton];
	
	_subscribedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 53.0, self.view.frame.size.width, self.view.frame.size.height - 53.0) style:UITableViewStylePlain];
	[_subscribedTableView setBackgroundColor:[UIColor whiteColor]];
	_subscribedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_subscribedTableView.rowHeight = 74.0;
	_subscribedTableView.delegate = self;
	_subscribedTableView.dataSource = self;
	_subscribedTableView.scrollsToTop = NO;
	_subscribedTableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_subscribedTableView];
	
	_popularTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 53.0, self.view.frame.size.width, self.view.frame.size.height - 53.0) style:UITableViewStylePlain];
	[_popularTableView setBackgroundColor:[UIColor whiteColor]];
	_popularTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_popularTableView.rowHeight = 74.0;
	_popularTableView.delegate = self;
	_popularTableView.dataSource = self;
	_popularTableView.scrollsToTop = NO;
	_popularTableView.showsVerticalScrollIndicator = NO;
	_popularTableView.hidden = YES;
	[self.view addSubview:_popularTableView];
	
	_subscribedHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_subscribedHeaderView.delegate = self;
	[_subscribedTableView addSubview:_subscribedHeaderView];
	[_subscribedHeaderView refreshLastUpdatedDate];
	
	_popularHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_popularHeaderView.delegate = self;
	[_popularTableView addSubview:_popularHeaderView];
	[_popularHeaderView refreshLastUpdatedDate];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	[self.navigationController pushViewController:[[[SNSubscribedListsViewController_iPhone alloc] initWithAnimation:_isIntro] autorelease] animated:NO];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


#pragma mark - Navigation
-(void)_goListsToggle {
	_isFollowingList = !_isFollowingList;
	
	_toggleLtImgView.hidden = !_isFollowingList;
	_toggleRtImgView.hidden = _isFollowingList;
	
	_subscribedTableView.hidden = !_isFollowingList;
	_popularTableView.hidden = _isFollowingList;
}

-(void)_goOptions {
	SNOptionsViewController_iPhone *optionsViewController = [[[SNOptionsViewController_iPhone alloc] init] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:optionsViewController] autorelease];
	
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController presentModalViewController:navigationController animated:YES];
}

-(void)_goSubscribedLists {
	[self.navigationController pushViewController:[[[SNSubscribedListsViewController_iPhone alloc] initWithAnimation:NO] autorelease] animated:YES];
}


- (void)reloadTableViewDataSource {
	_reloading = YES;
	
	if (!_isFollowingList) {
		_updateRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
		[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
		[_updateRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_updateRequest setDelegate:self];
		[_updateRequest startAsynchronous];
	}
}

- (void)doneLoadingTableViewData {
	_reloading = NO;
	
	if (_isFollowingList)
		[_subscribedHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_subscribedTableView];
	
	else
		[_popularHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_popularTableView];
}


#pragma mark - Notification handlers
-(void)_refreshSubscribedList:(NSNotification *)notification {
	NSLog(@"REFRESHING");
	
	_subscribedListsRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
	[_subscribedListsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[_subscribedListsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[_subscribedListsRequest setDelegate:self];
	[_subscribedListsRequest startAsynchronous];
}

#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([tableView isEqual:_subscribedTableView]) {
		return ([_subscribedLists count]);
		
	} else {
		return ([_popularLists count]);
	}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNRootListViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNRootListViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[[SNRootListViewCell_iPhone alloc] init] autorelease];
	
	if ([tableView isEqual:_subscribedTableView])
		cell.listVO = (SNListVO *)[_subscribedLists objectAtIndex:indexPath.row];
	
	else
		cell.listVO = (SNListVO *)[_popularLists objectAtIndex:indexPath.row];
		
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (74.0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	if ([tableView isEqual:_popularTableView]) {
		NSLog(@"SELECTED %@", ((SNListVO *)[_popularLists objectAtIndex:indexPath.row]).list_name);
		[self.navigationController pushViewController:[[[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[_popularLists objectAtIndex:indexPath.row]] autorelease] animated:YES];
		
	} else if ([tableView isEqual:_subscribedTableView]) {
		NSLog(@"SELECTED %@", ((SNListVO *)[_subscribedLists objectAtIndex:indexPath.row]).list_name);
		[self.navigationController pushViewController:[[[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[_subscribedLists objectAtIndex:indexPath.row]] autorelease] animated:YES];
	}
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_isFollowingList)
		[_subscribedHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
	else
		[_popularHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (_isFollowingList)
		[_subscribedHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
	else
		[_popularHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self reloadTableViewDataSource];
	
	if (_isFollowingList)
		[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date]; // should return date data source was last change	
}



#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	//NSLog(@"SNRootViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:_subscribedListsRequest]) {	
		@autoreleasepool {
			NSError *error = nil;
			NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
			NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			NSArray *parsedLists = [unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
			
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *list = [NSMutableArray array];
				for (NSDictionary *serverList in parsedLists) {
					SNListVO *vo = [SNListVO listWithDictionary:serverList];
					NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
					
					if (vo != nil)
						[list addObject:vo];
				}
				
				_subscribedLists = [list retain];
				[_subscribedTableView reloadData];
			}
			
			//EGOImageLoader *firstCover = [[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:((SNListVO *)[_subscribedLists objectAtIndex:0]).imageURL] shouldLoadWithObserver:nil];
		}
	
	} else if ([request isEqual:_popularListsRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"likes" ascending:NO] autorelease];
			NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			NSArray *parsedLists = [unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
			
			//NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *list = [NSMutableArray array];
				for (NSDictionary *serverList in parsedLists) {
					SNListVO *vo = [SNListVO listWithDictionary:serverList];
					NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
					
					if (vo != nil)
						[list addObject:vo];
				}
				
				_popularLists = [list retain];
				[_popularTableView reloadData];
			}
			
			if ([SNAppDelegate twitterHandle]) {
				_userRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]] retain];
				[_userRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
				[_userRequest setPostValue:[SNAppDelegate deviceToken] forKey:@"token"];
				[_userRequest setPostValue:[SNAppDelegate twitterHandle] forKey:@"handle"];
				[_userRequest setDelegate:self];
				[_userRequest startAsynchronous];			
			}
		}
		
	} else if ([request isEqual:_userRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSDictionary *parsedUser = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				[SNAppDelegate writeUserProfile:parsedUser];
			}
		}
		
		if ([[[SNAppDelegate profileForUser] objectForKey:@"name"] isEqualToString:@""]) {		
			_twitterRequest = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@", [SNAppDelegate twitterHandle]]]] retain];
			[_twitterRequest setDelegate:self];
			[_twitterRequest startAsynchronous];
		
		} else {
			[_subscribedListsRequest startAsynchronous];
		}
		
	} else if ([request isEqual:_twitterRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSDictionary *parsedUser = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			
			NSLog(@"NAME:%@", [parsedUser objectForKey:@"name"]);
			_userRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]] retain];
			[_userRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
			[_userRequest setPostValue:[parsedUser objectForKey:@"name"] forKey:@"userName"];
			[_userRequest setDelegate:self];
			[_userRequest startAsynchronous];
		}
		
		[_subscribedListsRequest startAsynchronous];
	
	} else if ([request isEqual:_updateRequest]) {
		if (_isFollowingList) {
			
		} else {
			@autoreleasepool {
				NSError *error = nil;
				NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"likes" ascending:NO] autorelease];
				NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				NSArray *parsedLists = [unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
				
				//NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				if (error != nil)
					NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
				else {
					NSMutableArray *list = [NSMutableArray array];
					for (NSDictionary *serverList in parsedLists) {
						SNListVO *vo = [SNListVO listWithDictionary:serverList];
						NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
						
						if (vo != nil)
							[list addObject:vo];
					}
					
					_popularLists = [list retain];
					[_popularTableView reloadData];
				}
			}
			
			[self doneLoadingTableViewData];
		}
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	if (request == _subscribedListsRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}


@end
