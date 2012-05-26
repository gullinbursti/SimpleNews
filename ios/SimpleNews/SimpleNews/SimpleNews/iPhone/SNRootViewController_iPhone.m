//
//  SNRootViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "GANTracker.h"

#import "SNRootViewController_iPhone.h"
#import "SNListVO.h"
#import "SNTopicVO.h"

#import "SNProfileViewController_iPhone.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNBaseRootListViewCell_iPhone.h"
#import "SNAnyListViewCell_iPhone.h"
#import "SNRootTopicViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNArticleCommentsViewController_iPhone.h"

#import "MBProgressHUD.h"
#import "MBLResourceLoader.h"

@interface SNRootViewController_iPhone () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *topicsListResource;
- (void)_refreshUserAccount;
- (void)_refreshTopicsList;
@end

@implementation SNRootViewController_iPhone

@synthesize topicsListResource = _topicsListResource;

- (id)init {
	if ((self = [super init])) {
		_topicCells = [NSMutableArray new];
		_topicsList = [NSMutableArray new];
		
		_isIntro = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showShareSheet:) name:@"SHOW_SHARE_SHEET" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticlePage:) name:@"SHOW_ARTICLE_PAGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleComments:) name:@"SHOW_ARTICLE_COMMENTS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_timelineReturn:) name:@"TIMELINE_RETURN" object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	self.topicsListResource = nil;
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	//_holderView = [[UIView alloc] initWithFrame:CGRectMake(-270.0, 0.0, 580.0, self.view.frame.size.height)];
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 580.0, self.view.frame.size.height)];
	[self.view addSubview:_holderView];
	
	_profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_profileButton.frame = CGRectMake(11.0, 9.0, 44.0, 44.0);
	[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive.png"] forState:UIControlStateNormal];
	[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_Active.png"] forState:UIControlStateHighlighted];
	[_profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[_holderView addSubview:_profileButton];
	
	_topicsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 50.0, 248.0, self.view.frame.size.height - 50.0) style:UITableViewStylePlain];
	[_topicsTableView setBackgroundColor:[UIColor clearColor]];
	_topicsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_topicsTableView.rowHeight = 50.0;
	_topicsTableView.delegate = self;
	_topicsTableView.dataSource = self;
	_topicsTableView.scrollsToTop = NO;
	_topicsTableView.showsVerticalScrollIndicator = NO;
	[_holderView addSubview:_topicsTableView];
	
	_cardListsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cardListsButton.frame = CGRectMake(276.0, 49.0, 44.0, self.view.frame.size.height - 49.0);
	[_cardListsButton addTarget:self action:@selector(_goCardLists) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_cardListsButton];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	_holderView = nil;
	_profileButton = nil;
	_topicsTableView = nil;
	_cardListsButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_shadowImgView.alpha = 1.0;
	}];
	
	// Refresh any network resources that need loading
	[self _refreshTopicsList];
	[self _refreshUserAccount];
}

#pragma mark - Navigation

- (void)_goCardLists {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_cardListsButton.hidden = YES;
		_topicTimelineView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
	}];
}

-(void)_goProfile {
	
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	} else {
		[UIView animateWithDuration:0.33
						 animations:^(void) {
							 _shadowImgView.alpha = 0.0;
			
						 }
						 completion:^(BOOL finished) {
							 SNProfileViewController_iPhone *profileViewController = [[SNProfileViewController_iPhone alloc] init];
							 [self.navigationController pushViewController:profileViewController animated:YES];
						 }];
	}
}

#pragma mark - Network Requests
- (void)setTopicsListResource:(MBLAsyncResource *)topicsListResource
{
	if (_topicsListResource != nil) {
		[_topicsListResource unsubscribe:self];
		_topicsListResource = nil;
	}
	
	_topicsListResource = topicsListResource;
	
	if (_topicsListResource != nil)
		[_topicsListResource subscribe:self];
}

- (void)_refreshTopicsList
{
	if (_topicsListResource == nil) {
		_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_hud.labelText = NSLocalizedString(@"Loading Topics…", @"Status message when loading topics list");
		_hud.mode = MBProgressHUDModeIndeterminate;
		_hud.graceTime = 2.0;
		_hud.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Topics.php"];
		self.topicsListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate date]]; // 1 hour expiration for now
	}
}

- (void)_refreshUserAccount
{
	if ((_userResource == nil) && ([SNAppDelegate twitterHandle] != nil)) {
		NSMutableDictionary *userFormValues = [NSMutableDictionary dictionary];
		[userFormValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[userFormValues setObject:[SNAppDelegate deviceToken] forKey:@"token"];
		[userFormValues setObject:[SNAppDelegate twitterHandle] forKey:@"handle"]; 
		[userFormValues setObject:[SNAppDelegate twitterID] forKey:@"twitterID"]; 
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"];
		_userResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:userFormValues forceFetch:YES expiration:[NSDate date]];
		[_userResource subscribe:self];
	}
}

- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data
{
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	if (resource == _userResource) {
		_hud.taskInProgress = NO;
		
		NSError *error = nil;
		NSDictionary *parsedUser = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error != nil) {
			NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			_hud.graceTime = 0.0;
			_hud.mode = MBProgressHUDModeCustomView;
			_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_hud.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_hud show:NO];
			[_hud hide:YES afterDelay:1.5];
			_hud = nil;
		}
		else {
			//_twitterRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@", [SNAppDelegate twitterHandle]]]];
			//[_twitterRequest setDelegate:self];
			//[_twitterRequest startAsynchronous];
			
			[SNAppDelegate writeUserProfile:parsedUser];
			
			[_hud hide:YES];
			_hud = nil;
		}
	}
	
	else if (resource == _topicsListResource) {
		_hud.taskInProgress = NO;
		
		NSError *error = nil;
		//NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		//NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
			_hud.graceTime = 0.0;
			_hud.mode = MBProgressHUDModeCustomView;
			_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_hud.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_hud show:NO];
			[_hud hide:YES afterDelay:1.5];
			_hud = nil;
		}
		else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNTopicVO *vo = [SNTopicVO topicWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
			}
			
			[_hud hide:YES];
			_hud = nil;
			
			_topicsList = list;
			[_topicsTableView reloadData];
			
			_topicTimelineView = [[SNTopicTimelineView_iPhone alloc] initWithPopularArticles];
			[_holderView addSubview:_topicTimelineView];
		}
	}
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error
{
	if (_hud != nil) {
		_hud.graceTime = 0.0;
		_hud.mode = MBProgressHUDModeCustomView;
		_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
		_hud.labelText = NSLocalizedString(@"Error", @"Error");
		[_hud show:NO];
		[_hud hide:YES afterDelay:1.5];
		_hud = nil;
	}
	
	// Show an error overlay?
	
	if (resource == _userResource)
		_userResource = nil;
}

#pragma mark - Notification handlers

-(void)_showArticleComments:(NSNotification *)notification {
	SNArticleCommentsViewController_iPhone *articleCommentsViewController = [[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object] listID:0];
	[self.navigationController pushViewController:articleCommentsViewController animated:YES];
}

-(void)_showArticlePage:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:vo.article_url] title:vo.title];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showShareSheet:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:vo.article_url] title:vo.title];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}


-(void)_timelineReturn:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_topicTimelineView.frame = CGRectMake(276.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_cardListsButton.hidden = NO;
	}];
}

-(void)_twitterShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
	
	//[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
	[twitter addURL:[NSURL URLWithString:[NSString stringWithString:[NSString stringWithFormat:@"http://assemb.ly/tweets?id=%@", vo.tweet_id]]]];
	[twitter setInitialText:[NSString stringWithFormat:@"via Assembly - %@", vo.title]];
	
	[self presentModalViewController:twitter animated:YES];
	
	twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
		
		ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", vo.list_id] forKey:@"listID"];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", vo.article_id] forKey:@"articleID"];
		[readRequest setDelegate:self];
		[readRequest startAsynchronous];
				
		[self dismissModalViewControllerAnimated:YES];
	};
}



#pragma mark - TableView DataSource Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_topicsList count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNRootTopicViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNRootTopicViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNRootTopicViewCell_iPhone alloc] init];
		
	cell.topicVO = (SNTopicVO *)[_topicsList objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[_topicCells addObject:cell];
	return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (50.0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_topicTimelineView removeFromSuperview];
	_topicTimelineView = nil;
	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_shadowImgView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		
		if (indexPath.row == 0)
			_topicTimelineView = [[SNTopicTimelineView_iPhone alloc] initWithPopularArticles];	
		
		else
			_topicTimelineView = [[SNTopicTimelineView_iPhone alloc] initWithTopicVO:(SNTopicVO *)[_topicsList objectAtIndex:indexPath.row]];
		
		[_holderView addSubview:_topicTimelineView];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_cardListsButton.hidden = YES;
			_topicTimelineView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
			
		} completion:^(BOOL finished) {
		}];
	}];
}

#pragma mark - ScrollView Delegates


@end