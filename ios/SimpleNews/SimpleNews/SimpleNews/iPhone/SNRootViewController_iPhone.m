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

#import "SNWebPageViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNArticleListViewController_iPhone.h"
#import "SNRootListViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNOptionsViewController_iPhone.h"
#import "SNArticleListViewController_iPhone.h"
#import "SNCardListsView_iPhone.h"

@interface SNRootViewController_iPhone()
-(void)_goListsToggle;
@end

@implementation SNRootViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_subscribedLists = [NSMutableArray new];
		_popularLists = [NSMutableArray new];
		
		_isIntro = YES;
		_isFollowingList = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_listArticles:) name:@"LIST_ARTICLES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSubscribedList:) name:@"REFRESH_SUBSCRIBED_LIST" object:nil];
		
		_popularListsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
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
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(-270.0, 0.0, 580.0, self.view.frame.size.height)];
	_holderView.userInteractionEnabled = YES;
	[self.view addSubview:_holderView];
	
	UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
	plusButton.frame = CGRectMake(12.0, 8.0, 44.0, 44.0);
	[plusButton setBackgroundImage:[UIImage imageNamed:@"plusButton_nonActive.png"] forState:UIControlStateNormal];
	[plusButton setBackgroundImage:[UIImage imageNamed:@"plusButton_Active.png"] forState:UIControlStateHighlighted];
	[plusButton addTarget:self action:@selector(_goCreateList) forControlEvents:UIControlEventTouchUpInside];
	[_holderView addSubview:plusButton];
	
	_toggleLtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(78.0, 15.0, 164.0, 34.0)];
	_toggleLtImgView.image = [UIImage imageNamed:@"toggleBGLeft.png"];
	[_holderView addSubview:_toggleLtImgView];
	
	UILabel *followingOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 9.0, 100.0, 16.0)];
	followingOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	followingOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	followingOnLabel.backgroundColor = [UIColor clearColor];
	followingOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	followingOnLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	followingOnLabel.text = @"Following";
	[_toggleLtImgView addSubview:followingOnLabel];
	
	UILabel *popularOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 9.0, 100.0, 16.0)];
	popularOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	popularOffLabel.textColor = [UIColor blackColor];
	popularOffLabel.backgroundColor = [UIColor clearColor];
	popularOffLabel.text = @"Popular";
	[_toggleLtImgView addSubview:popularOffLabel];
	
	_toggleRtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(78.0, 15.0, 164.0, 34.0)];
	_toggleRtImgView.image = [UIImage imageNamed:@"toggleBGRight.png"];
	_toggleRtImgView.hidden = YES;
	[_holderView addSubview:_toggleRtImgView];
	
	UILabel *followingOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 9.0, 100.0, 16.0)];
	followingOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	followingOffLabel.textColor = [UIColor blackColor];
	followingOffLabel.backgroundColor = [UIColor clearColor];
	followingOffLabel.text = @"Following";
	[_toggleRtImgView addSubview:followingOffLabel];
	
	UILabel *popularOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 9.0, 100.0, 16.0)];
	popularOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	popularOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	popularOnLabel.backgroundColor = [UIColor clearColor];
	popularOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	popularOnLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	popularOnLabel.text = @"Popular";
	[_toggleRtImgView addSubview:popularOnLabel];
	
	UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toggleButton.frame = CGRectMake(78.0, 4.0, 164.0, 44.0);
	[toggleButton addTarget:self action:@selector(_goListsToggle) forControlEvents:UIControlEventTouchUpInside];
	[_holderView addSubview:toggleButton];
	
	_subscribedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 53.0, 270.0, self.view.frame.size.height - 53.0) style:UITableViewStylePlain];
	[_subscribedTableView setBackgroundColor:[UIColor clearColor]];
	_subscribedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_subscribedTableView.rowHeight = 80.0;
	_subscribedTableView.delegate = self;
	_subscribedTableView.dataSource = self;
	_subscribedTableView.scrollsToTop = NO;
	_subscribedTableView.showsVerticalScrollIndicator = NO;
	[_holderView addSubview:_subscribedTableView];
	
	_popularTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 53.0, 270.0, self.view.frame.size.height - 53.0) style:UITableViewStylePlain];
	[_popularTableView setBackgroundColor:[UIColor clearColor]];
	_popularTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_popularTableView.rowHeight = 80.0;
	_popularTableView.delegate = self;
	_popularTableView.dataSource = self;
	_popularTableView.scrollsToTop = NO;
	_popularTableView.showsVerticalScrollIndicator = NO;
	_popularTableView.hidden = YES;
	[_holderView addSubview:_popularTableView];
	
	_subscribedHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_subscribedHeaderView.delegate = self;
	[_subscribedTableView addSubview:_subscribedHeaderView];
	[_subscribedHeaderView refreshLastUpdatedDate];
	
	_popularHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_popularHeaderView.delegate = self;
	[_popularTableView addSubview:_popularHeaderView];
	[_popularHeaderView refreshLastUpdatedDate];
	
	_cardListsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	//[_cardListsButton setBackgroundColor:[SNAppDelegate snDebugGreenColor]];
	_cardListsButton.frame = CGRectMake(280.0, 15.0, 40.0, 423.0);
	[_cardListsButton addTarget:self action:@selector(_goCardLists) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_cardListsButton];
	
	UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	optionsButton.frame = CGRectMake(540.0, 440.0, 44.0, 44.0);
	[optionsButton setBackgroundImage:[UIImage imageNamed:@"gearButton_nonActive.png"] forState:UIControlStateNormal];
	[optionsButton setBackgroundImage:[UIImage imageNamed:@"gearButton_Active.png"] forState:UIControlStateHighlighted];
	[optionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
	[_holderView addSubview:optionsButton];
	
	_rootListButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_rootListButton.frame = CGRectMake(-64.0, -64.0, 64.0, 64.0);
	[_rootListButton setBackgroundImage:[UIImage imageNamed:@"topLeft_nonActive.png"] forState:UIControlStateNormal];
	[_rootListButton setBackgroundImage:[UIImage imageNamed:@"topLeft_Active.png"] forState:UIControlStateHighlighted];
	[_rootListButton addTarget:self action:@selector(_goRootLists) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_rootListButton];
	
	UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_rootListButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
	} completion:nil];
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

-(void)_goRootLists {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_rootListButton.frame = CGRectMake(-64.0, -64.0, 64.0, 64.0);
		_holderView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_cardListsButton.hidden = NO;
	}];
}

-(void)_goCardLists {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_cardListsButton.hidden = YES;
		_holderView.frame = CGRectMake(-270.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.33 animations:^(void) {
			_rootListButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
		} completion:nil];
	}];
}

-(void)_goCreateList {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create a List" message:@"This feature is coming soon" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

-(void)_goOptions {
	[self.navigationController pushViewController:[[SNOptionsViewController_iPhone alloc] init] animated:YES];
}


- (void)reloadTableViewDataSource {
	_reloading = YES;
	
	if (!_isFollowingList) {
		_updateRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
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

- (void)_refreshSubscribedList:(NSNotification *)notification {
	if (_subscribedListsRequest == nil) {
		NSLog(@"REFRESHING SUBSCRIBED LISTS");
		_subscribedListsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[_subscribedListsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_subscribedListsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_subscribedListsRequest setDelegate:self];
		[_subscribedListsRequest startAsynchronous];
	}
}

-(void)_listArticles:(NSNotification *)notification {
	SNArticleListViewController_iPhone *articleListViewController = [[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[notification object]];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:articleListViewController animated:YES];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:webPageViewController animated:YES];
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
		cell = [[SNRootListViewCell_iPhone alloc] init];
	
	if ([tableView isEqual:_subscribedTableView])
		cell.listVO = (SNListVO *)[_subscribedLists objectAtIndex:indexPath.row];
	
	else
		cell.listVO = (SNListVO *)[_popularLists objectAtIndex:indexPath.row];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (80.0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	if ([tableView isEqual:_popularTableView]) {
		NSLog(@"SELECTED %@", ((SNListVO *)[_popularLists objectAtIndex:indexPath.row]).list_name);
		[self.navigationController pushViewController:[[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[_popularLists objectAtIndex:indexPath.row]] animated:YES];
		
	} else if ([tableView isEqual:_subscribedTableView]) {
		NSLog(@"SELECTED %@", ((SNListVO *)[_subscribedLists objectAtIndex:indexPath.row]).list_name);
		[self.navigationController pushViewController:[[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[_subscribedLists objectAtIndex:indexPath.row]] animated:YES];
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
			NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
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
				
				_subscribedLists = [list copy];
				[_subscribedTableView reloadData];
			}
			
			//EGOImageLoader *firstCover = [[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:((SNListVO *)[_subscribedLists objectAtIndex:0]).imageURL] shouldLoadWithObserver:nil];
		}
		_subscribedListsRequest = nil;
		
	} else if ([request isEqual:_popularListsRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"likes" ascending:NO];
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
				
				_popularLists = [list copy];
				[_popularTableView reloadData];
			}
			
			if ([SNAppDelegate twitterHandle]) {
				_userRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]];
				[_userRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
				[_userRequest setPostValue:[SNAppDelegate deviceToken] forKey:@"token"];
				[_userRequest setPostValue:[SNAppDelegate twitterHandle] forKey:@"handle"];
				[_userRequest setDelegate:self];
				[_userRequest startAsynchronous];			
			}
			
			SNCardListsView_iPhone *cardListsView = [[SNCardListsView_iPhone alloc] initWithLists:unsortedLists];
			[_holderView addSubview:cardListsView];
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
			_twitterRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@", [SNAppDelegate twitterHandle]]]];
			[_twitterRequest setDelegate:self];
			[_twitterRequest startAsynchronous];
			
		} else {
			[self _refreshSubscribedList:nil];
		}
		
	} else if ([request isEqual:_twitterRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSDictionary *parsedUser = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			
			NSLog(@"NAME:%@", [parsedUser objectForKey:@"name"]);
			_userRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]];
			[_userRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
			[_userRequest setPostValue:[parsedUser objectForKey:@"name"] forKey:@"userName"];
			[_userRequest setDelegate:self];
			[_userRequest startAsynchronous];
		}
		
		[self _refreshSubscribedList:nil];
		
	} else if ([request isEqual:_updateRequest]) {
		if (_isFollowingList) {
			
		} else {
			@autoreleasepool {
				NSError *error = nil;
				NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"likes" ascending:NO];
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
					
					_popularLists = [list copy];
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
		_subscribedListsRequest = nil;
	}
	
	//[_loadOverlay remove];
}


@end