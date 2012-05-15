//
//  SNRootViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GANTracker.h"

#import "SNRootViewController_iPhone.h"
#import "SNListVO.h"
#import "SNOptionVO.h"

#import "SNProfileViewController_iPhone.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNBaseRootListViewCell_iPhone.h"
#import "SNAnyListViewCell_iPhone.h"
#import "SNFollowingListViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNArticleListViewController_iPhone.h"
#import "SNArticleListView_iPhone.h"
#import "SNDiscoveryArticlesView_iPhone.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNArticleSourcesViewController_iPhone.h"
#import "SNArticleCommentsViewController_iPhone.h"

#import "MBProgressHUD.h"
#import "MBLResourceLoader.h"

@interface SNRootViewController_iPhone () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *popularListsResource;
@property(nonatomic, strong) MBLAsyncResource *subscribedListsResource;
- (void)_goListsToggle;
@end

@implementation SNRootViewController_iPhone

@synthesize popularListsResource = _popularListsResource;
@synthesize subscribedListsResource = _subscribedListsResource;

- (id)init {
	if ((self = [super init])) {
		_subscribedLists = [NSMutableArray new];
		_popularLists = [NSMutableArray new];
		
		_isIntro = YES;
		_isFollowingList = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSubscribedLists:) name:@"REFRESH_SUBSCRIBED_LIST" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleDetails:) name:@"SHOW_ARTICLE_DETAILS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleSources:) name:@"SHOW_ARTICLE_SOURCES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showComments:) name:@"SHOW_COMMENTS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_articlesReturn:) name:@"ARTICLES_RETURN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_listSubscribe:) name:@"LIST_SUBSCRIBE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_listUnsubscribe:) name:@"LIST_UNSUBSCRIBE" object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	self.popularListsResource = nil;
	self.subscribedListsResource = nil;
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	//_holderView = [[UIView alloc] initWithFrame:CGRectMake(-270.0, 0.0, 580.0, self.view.frame.size.height)];
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 580.0, self.view.frame.size.height)];
	[self.view addSubview:_holderView];
	
	_profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_profileButton.frame = CGRectMake(12.0, 8.0, 44.0, 44.0);
	[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive.png"] forState:UIControlStateNormal];
	[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_Active.png"] forState:UIControlStateHighlighted];
	[_profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[_holderView addSubview:_profileButton];
	
	_toggleLtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(78.0, 8.0, 164.0, 44.0)];
	_toggleLtImgView.image = [UIImage imageNamed:@"toggleBGLeft.png"];
	[_holderView addSubview:_toggleLtImgView];
	
	UILabel *followingOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 14.0, 100.0, 16.0)];
	followingOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	followingOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	followingOnLabel.backgroundColor = [UIColor clearColor];
	followingOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	followingOnLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	followingOnLabel.text = @"Following";
	[_toggleLtImgView addSubview:followingOnLabel];
	
	UILabel *popularOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(91.0, 14.0, 100.0, 16.0)];
	popularOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	popularOffLabel.textColor = [UIColor blackColor];
	popularOffLabel.backgroundColor = [UIColor clearColor];
	popularOffLabel.text = @"All Topics";
	[_toggleLtImgView addSubview:popularOffLabel];
	
	_toggleRtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(78.0, 8.0, 164.0, 44.0)];
	_toggleRtImgView.image = [UIImage imageNamed:@"toggleBGRight.png"];
	_toggleRtImgView.hidden = YES;
	[_holderView addSubview:_toggleRtImgView];
	
	UILabel *followingOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 14.0, 100.0, 16.0)];
	followingOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	followingOffLabel.textColor = [UIColor blackColor];
	followingOffLabel.backgroundColor = [UIColor clearColor];
	followingOffLabel.text = @"Following";
	[_toggleRtImgView addSubview:followingOffLabel];
	
	UILabel *popularOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(91.0, 14.0, 100.0, 16.0)];
	popularOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	popularOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	popularOnLabel.backgroundColor = [UIColor clearColor];
	popularOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	popularOnLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	popularOnLabel.text = @"All Topics";
	[_toggleRtImgView addSubview:popularOnLabel];
	
	UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toggleButton.frame = CGRectMake(78.0, 4.0, 164.0, 44.0);
	[toggleButton addTarget:self action:@selector(_goListsToggle) forControlEvents:UIControlEventTouchUpInside];
	[_holderView addSubview:toggleButton];
	
	_subscribedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 53.0, 270.0, self.view.frame.size.height - 53.0) style:UITableViewStylePlain];
	[_subscribedTableView setBackgroundColor:[UIColor clearColor]];
	_subscribedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_subscribedTableView.rowHeight = 50.0;
	_subscribedTableView.delegate = self;
	_subscribedTableView.dataSource = self;
	_subscribedTableView.scrollsToTop = NO;
	_subscribedTableView.showsVerticalScrollIndicator = NO;
	[_holderView addSubview:_subscribedTableView];
	
	_popularTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 53.0, 270.0, self.view.frame.size.height - 53.0) style:UITableViewStylePlain];
	[_popularTableView setBackgroundColor:[UIColor clearColor]];
	_popularTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_popularTableView.rowHeight = 50.0;
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
	
	UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//_profileButton.hidden = YES;
	//_toggleLtImgView.hidden = YES;
	//_toggleRtImgView.hidden = YES;
	
//	[UIView animateWithDuration:0.33 animations:^(void) {
//		_holderView.frame = CGRectMake(-270.0, _holderView.frame.origin.y, _holderView.frame.size.width, _holderView.frame.size.height);
//	
//	} completion:^(BOOL finished) {
//		[UIView animateWithDuration:0.33 animations:^(void) {
//			_rootListButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
//		
//		} completion:^(BOOL finished) {
//			_profileButton.hidden = NO;
//			_toggleLtImgView.hidden = NO;
//			_toggleRtImgView.hidden = NO;
//		}];
//	}];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	_holderView = nil;
	_profileButton = nil;
	_toggleLtImgView = nil;
	_toggleRtImgView = nil;
	_subscribedTableView = nil;
	_popularTableView = nil;
	_subscribedHeaderView = nil;
	_popularHeaderView = nil;
	_cardListsButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Refresh any network resources that need loading
	[self _refreshPopularLists];
	[self _refreshUserAccount];
}

#pragma mark - Navigation

- (void)_goListsToggle {
	_isFollowingList = !_isFollowingList;
	
	_toggleLtImgView.hidden = !_isFollowingList;
	_toggleRtImgView.hidden = _isFollowingList;
	
	_subscribedTableView.hidden = !_isFollowingList;
	_popularTableView.hidden = _isFollowingList;
}

- (void)_goCardLists {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_cardListsButton.hidden = YES;
		_holderView.frame = CGRectMake(-270.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.33 animations:^(void) {
		} completion:nil];
	}];
}

- (void)_goProfile {
	[UIView animateWithDuration:0.125 animations:^(void) {
		_discoveryArticlesView.frame = CGRectMake(320.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
		
	}completion:^(BOOL finished) {
		_discoveryArticlesView.hidden = YES;
		SNProfileViewController_iPhone *profileViewController = [[SNProfileViewController_iPhone alloc] init];
		[self.navigationController pushViewController:profileViewController animated:YES];
	}];
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

#pragma mark - Network Requests

- (void)setPopularListsResource:(MBLAsyncResource *)popularListsResource
{
	if (_popularListsResource != nil) {
		[_popularListsResource unsubscribe:self];
		_popularListsResource = nil;
	}
	
	_popularListsResource = popularListsResource;
	
	if (_popularListsResource != nil)
		[_popularListsResource subscribe:self];
}

- (void)_refreshPopularLists
{
	if (_popularListsResource == nil) {
		_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_hud.labelText = NSLocalizedString(@"Loading Popular Lists...", @"Status message when loading popular lists");
		_hud.mode = MBProgressHUDModeIndeterminate;
		_hud.graceTime = 2.0;
		_hud.taskInProgress = YES;
		
		NSString *userId = [[SNAppDelegate profileForUser] objectForKey:@"id"];
		NSMutableDictionary *popularListFormValues = [NSMutableDictionary dictionary];
		[popularListFormValues setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
		[popularListFormValues setObject:(userId != nil ? userId : [NSString stringWithFormat:@"%d", 0]) forKey:@"userID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"];
		self.popularListsResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:popularListFormValues forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0)]]; // 1 hour expiration for now
	}
}

- (void)_refreshUserAccount
{
	if ((_userResource == nil) && ([SNAppDelegate twitterHandle] != nil)) {
		NSMutableDictionary *userFormValues = [NSMutableDictionary dictionary];
		[userFormValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[userFormValues setObject:[SNAppDelegate deviceToken] forKey:@"token"];
		[userFormValues setObject:[SNAppDelegate twitterHandle] forKey:@"handle"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"];
		_userResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:userFormValues forceFetch:YES expiration:[NSDate date]];
		[_userResource subscribe:self];
	}
}

- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data
{
	if (resource == _popularListsResource) {
		_hud.taskInProgress = NO;
		
		NSError *error = nil;
		NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error != nil) {
			NSLog(@"Failed to parse popular lists JSON: %@", [error localizedDescription]);
			_hud.graceTime = 0.0;
			_hud.mode = MBProgressHUDModeCustomView;
			_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_hud.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_hud show:NO];
			[_hud hide:YES afterDelay:1.5];
			_hud = nil;
		}
		else {
			NSMutableArray *popularLists = [NSMutableArray array];
			NSArray *sortedByLikes = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"likes" ascending:NO]];
			for (NSDictionary *list in [unsortedLists sortedArrayUsingDescriptors:sortedByLikes]) {
				SNListVO *vo = [SNListVO listWithDictionary:list];
				if (vo != nil)
					[popularLists addObject:vo];
			}
			
			_popularLists = popularLists;
			[_popularTableView reloadData];
			
			_discoveryArticlesView = [[SNDiscoveryArticlesView_iPhone alloc] initWithFrame:CGRectMake(270.0, 0.0, 320.0, 480.0) listVO:(SNListVO *)[_popularLists objectAtIndex:0]];
			[_holderView addSubview:_discoveryArticlesView];
			
			_discoveryArticlesView.hidden = NO;
			[UIView animateWithDuration:0.33 animations:^(void) {
				_discoveryArticlesView.frame = CGRectMake(270.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
			}];
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_cardListsButton.hidden = YES;
				_holderView.frame = CGRectMake(-270.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
			}];
			
			[_hud hide:YES];
			_hud = nil;
		}
	}
	else if (resource == _userResource) {
		NSError *error = nil;
		NSDictionary *parsedUser = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error != nil) {
			NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
		}
		else {
			[SNAppDelegate writeUserProfile:parsedUser];
			[self _refreshSubscribedLists:nil];
		}
	}
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error
{
	// Show an error overlay?
	
	if (resource == _userResource)
		_userResource = nil;
}

#pragma mark - Notification handlers

- (void)setSubscribedListsResource:(MBLAsyncResource *)subscribedListsResource
{
	if (_subscribedListsResource != nil) {
		[_subscribedListsResource unsubscribe:self];
		_subscribedListsResource = nil;
	}
	
	_subscribedListsResource = subscribedListsResource;
	
	if (_subscribedListsResource != nil)
		[_subscribedListsResource subscribe:self];
}

- (void)_refreshSubscribedLists:(NSNotification *)notification {
	if ([[SNAppDelegate profileForUser] objectForKey:@"id"] != nil) {
		NSLog(@"REFRESHING SUBSCRIBED LISTS");
		
		NSMutableDictionary *subscribedListsFormValues = [NSMutableDictionary dictionary];
		[subscribedListsFormValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[subscribedListsFormValues setObject:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribedListsFormValues setObject:[SNAppDelegate twitterHandle] forKey:@"handle"];
		
		_subscribedListsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[_subscribedListsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_subscribedListsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_subscribedListsRequest setDelegate:self];
		[_subscribedListsRequest startAsynchronous];
	}
	else {
		NSLog(@"Can't refresh subscribed lists without a valid user id");
	}
}

-(void)_articlesReturn:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_holderView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_cardListsButton.hidden = NO;
	}];
}

-(void)_showComments:(NSNotification *)notification {
	SNArticleCommentsViewController_iPhone *articleCommentsViewController = [[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object] listID:0];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:articleCommentsViewController animated:YES];
}

-(void)_showArticleDetails:(NSNotification *)notification {
	SNArticleDetailsViewController_iPhone *articleDetailsViewController = [[SNArticleDetailsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object]];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:articleDetailsViewController animated:YES];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showArticleSources:(NSNotification *)notification {
	[self.navigationController pushViewController:[[SNArticleSourcesViewController_iPhone alloc] init] animated:YES];
}


-(void)_listSubscribe:(NSNotification *)notification {
	//NSLog(@"SUBSCRIBING");
	
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		
	} else {
		SNListVO *vo = (SNListVO *)[notification object];
		
		ASIFormDataRequest *subscribeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[subscribeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", vo.list_id] forKey:@"listID"];
		[subscribeRequest setDelegate:self];
		[subscribeRequest startAsynchronous];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"Following Topic" action:vo.list_name label:nil value:-1 withError:&error])
			NSLog(@"error in trackEvent");
	}
} 


-(void)_listUnsubscribe:(NSNotification *)notification {
	//NSLog(@"UNSUBSCRIBING");
	
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		
	} else {
		SNListVO *vo = (SNListVO *)[notification object];
		
		ASIFormDataRequest *subscribeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
		[subscribeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", vo.list_id] forKey:@"listID"];
		[subscribeRequest setDelegate:self];
		[subscribeRequest startAsynchronous];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"Unfollowed Topic" action:vo.list_name label:nil value:-1 withError:&error])
			NSLog(@"error in trackEvent");
	}
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
	
	if ([tableView isEqual:_subscribedTableView]) {
		SNFollowingListViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNFollowingListViewCell_iPhone cellReuseIdentifier]];
		
		if (cell == nil)
			cell = [[SNFollowingListViewCell_iPhone alloc] init];
			
		cell.listVO = (SNListVO *)[_subscribedLists objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return cell;	
	
	} else if ([tableView isEqual:_popularTableView]) {
		SNAnyListViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNAnyListViewCell_iPhone cellReuseIdentifier]];
		
		if (cell == nil)
			cell = [[SNAnyListViewCell_iPhone alloc] init];
		
		cell.listVO = (SNListVO *)[_popularLists objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return cell;	
	}
	
	return (nil);
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete)
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade]; 
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (50.0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	if ([tableView isEqual:_popularTableView]) {
		[UIView animateWithDuration:0.125 animations:^(void) {
			_discoveryArticlesView.frame = CGRectMake(320.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
			
		}completion:^(BOOL finished) {
			_discoveryArticlesView.hidden = YES;
			NSLog(@"SELECTED %@", ((SNListVO *)[_popularLists objectAtIndex:indexPath.row]).list_name);
			[self.navigationController setNavigationBarHidden:YES];
			[self.navigationController pushViewController:[[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[_popularLists objectAtIndex:indexPath.row]] animated:YES];
		}];
		
	} else if ([tableView isEqual:_subscribedTableView]) {
		[UIView animateWithDuration:0.125 animations:^(void) {
			_discoveryArticlesView.frame = CGRectMake(320.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
			
		}completion:^(BOOL finished) {
			_discoveryArticlesView.hidden = YES;
			NSLog(@"SELECTED %@", ((SNListVO *)[_subscribedLists objectAtIndex:indexPath.row]).list_name);
			[self.navigationController setNavigationBarHidden:YES];
			[self.navigationController pushViewController:[[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[_subscribedLists objectAtIndex:indexPath.row]] animated:YES];
		}];
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
					//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
					
					if (vo != nil)
						[list addObject:vo];
				}
				
				_subscribedLists = [list copy];
				[_subscribedTableView reloadData];
			}
			
			//EGOImageLoader *firstCover = [[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:((SNListVO *)[_subscribedLists objectAtIndex:0]).imageURL] shouldLoadWithObserver:nil];
		}
		_subscribedListsRequest = nil;
		
	}
	else if ([request isEqual:_updateRequest]) {
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
						//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
						
						if (vo != nil)
							[list addObject:vo];
					}
					
					_popularLists = [list copy];
					[_popularTableView reloadData];
				}
			}
			
			[self doneLoadingTableViewData];
		}
	
	} else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SUBSCRIBED_LIST" object:nil];
}

@end