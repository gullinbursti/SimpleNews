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
#import "SNDiscoveryArticlesView_iPhone.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNArticleSourcesViewController_iPhone.h"
#import "SNArticleCommentsViewController_iPhone.h"

#import "MBProgressHUD.h"
#import "MBLResourceLoader.h"

@interface SNRootViewController_iPhone () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *popularListsResource;
@property(nonatomic, strong) MBLAsyncResource *subscribedListsResource;
@property(nonatomic, strong) MBLAsyncResource *topicsListResource;
- (void)_goListsToggle;
- (void)_refreshPopularLists;
- (void)_refreshUserAccount;
- (void)_refreshTopicsList;
@end

@implementation SNRootViewController_iPhone

@synthesize popularListsResource = _popularListsResource;
@synthesize subscribedListsResource = _subscribedListsResource;
@synthesize topicsListResource = _topicsListResource;

- (id)init {
	if ((self = [super init])) {
		_popularLists = [NSMutableArray new];
		_subscribedCells = [NSMutableArray new];
		_topicsList = [NSMutableArray new];
		
		_isIntro = YES;
		_isFollowingList = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSubscribedLists:) name:@"REFRESH_SUBSCRIBED_LIST" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleDetails:) name:@"SHOW_ARTICLE_DETAILS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleSources:) name:@"SHOW_ARTICLE_SOURCES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleComments:) name:@"SHOW_ARTICLE_COMMENTS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticlePage:) name:@"SHOW_ARTICLE_PAGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_discoveryReturn:) name:@"DISCOVERY_RETURN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_timelineReturn:) name:@"TIMELINE_RETURN" object:nil];
		
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
	
	_toggleLtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(77.0, 9.0, 164.0, 44.0)];
	_toggleLtImgView.image = [UIImage imageNamed:@"toggleBGLeft.png"];
	[_holderView addSubview:_toggleLtImgView];
	
	UILabel *followingOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 15.0, 100.0, 14.0)];
	followingOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	followingOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	followingOnLabel.backgroundColor = [UIColor clearColor];
	followingOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	followingOnLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	followingOnLabel.text = @"Following";
	[_toggleLtImgView addSubview:followingOnLabel];
	
	UILabel *popularOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(98.0, 15.0, 100.0, 14.0)];
	popularOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	popularOffLabel.textColor = [UIColor blackColor];
	popularOffLabel.backgroundColor = [UIColor clearColor];
	popularOffLabel.text = @"All Topics";
	[_toggleLtImgView addSubview:popularOffLabel];
	
	_toggleRtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(78.0, 9.0, 164.0, 44.0)];
	_toggleRtImgView.image = [UIImage imageNamed:@"toggleBGRight.png"];
	_toggleRtImgView.hidden = YES;
	[_holderView addSubview:_toggleRtImgView];
	
	UILabel *followingOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 15.0, 100.0, 14.0)];
	followingOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	followingOffLabel.textColor = [UIColor blackColor];
	followingOffLabel.backgroundColor = [UIColor clearColor];
	followingOffLabel.text = @"Following";
	[_toggleRtImgView addSubview:followingOffLabel];
	
	UILabel *popularOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(98.0, 15.0, 100.0, 14.0)];
	popularOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	popularOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	popularOnLabel.backgroundColor = [UIColor clearColor];
	popularOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	popularOnLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	popularOnLabel.text = @"All Topics";
	[_toggleRtImgView addSubview:popularOnLabel];
	
	UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toggleButton.frame = CGRectMake(78.0, 8.0, 164.0, 44.0);
	[toggleButton addTarget:self action:@selector(_goListsToggle) forControlEvents:UIControlEventTouchUpInside];
	[_holderView addSubview:toggleButton];
	
	_topicsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 50.0, 248.0, self.view.frame.size.height - 50.0) style:UITableViewStylePlain];
	[_topicsTableView setBackgroundColor:[UIColor clearColor]];
	_topicsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_topicsTableView.rowHeight = 50.0;
	_topicsTableView.delegate = self;
	_topicsTableView.dataSource = self;
	_topicsTableView.scrollsToTop = NO;
	_topicsTableView.showsVerticalScrollIndicator = NO;
	[_holderView addSubview:_topicsTableView];
	
	_popularTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 50.0, 248.0, self.view.frame.size.height - 50.0) style:UITableViewStylePlain];
	[_popularTableView setBackgroundColor:[UIColor clearColor]];
	_popularTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_popularTableView.rowHeight = 50.0;
	_popularTableView.delegate = self;
	_popularTableView.dataSource = self;
	_popularTableView.scrollsToTop = NO;
	_popularTableView.showsVerticalScrollIndicator = NO;
	_popularTableView.hidden = YES;
	[_holderView addSubview:_popularTableView];
	
	_cardListsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cardListsButton.frame = CGRectMake(276.0, 49.0, 44.0, self.view.frame.size.height - 49.0);
	[_cardListsButton addTarget:self action:@selector(_goCardLists) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_cardListsButton];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	_holderView = nil;
	_profileButton = nil;
	_toggleLtImgView = nil;
	_toggleRtImgView = nil;
	_topicsTableView = nil;
	_popularTableView = nil;
	_cardListsButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_discoveryArticlesView.hidden = NO;
//	[UIView animateWithDuration:0.33 animations:^(void) {
//		_discoveryArticlesView.alpha = 1.0;
//		_shadowImgView.alpha = 1.0;
//	}];
	// Refresh any network resources that need loading
	[self _refreshTopicsList];
	[self _refreshUserAccount];
}

#pragma mark - Navigation

- (void)_goListsToggle {
	_isFollowingList = !_isFollowingList;
	
	_toggleLtImgView.hidden = !_isFollowingList;
	_toggleRtImgView.hidden = _isFollowingList;
	
	_topicsTableView.hidden = !_isFollowingList;
	_popularTableView.hidden = _isFollowingList;
}

- (void)_goCardLists {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_cardListsButton.hidden = YES;
		_holderView.frame = CGRectMake(-276.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
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
							 _discoveryArticlesView.alpha = 0.0;
							 _shadowImgView.alpha = 0.0;
			
						 }
						 completion:^(BOOL finished) {
							 _discoveryArticlesView.hidden = YES;
							 SNProfileViewController_iPhone *profileViewController = [[SNProfileViewController_iPhone alloc] init];
							 [self.navigationController pushViewController:profileViewController animated:YES];
						 }];
	}
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
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"];
		_userResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:userFormValues forceFetch:YES expiration:[NSDate date]];
		[_userResource subscribe:self];
	}
}

- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data
{
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
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

			_shadowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(256.0, 0.0, 30.0, _holderView.frame.size.height)];
			_shadowImgView.image = [UIImage imageNamed:@"shadow.png"];
			//[_shadowImgView setBackgroundColor:[SNAppDelegate snDebugRedColor]];
			//_shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
			//_shadowView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
			//_shadowView.layer.shadowOpacity = 0.5;
			//_shadowView.layer.shouldRasterize = YES;
			//_shadowView.layer.shadowRadius = 8.0;
			_shadowImgView.alpha = 0.0;
			[_holderView addSubview:_shadowImgView];
			
			_discoveryArticlesView = [[SNDiscoveryArticlesView_iPhone alloc] initWithFrame:CGRectMake(270.0, 0.0, 320.0, 480.0) listVO:(SNListVO *)[_popularLists objectAtIndex:0]];
			[_holderView addSubview:_discoveryArticlesView];
			
			_discoveryArticlesView.hidden = NO;
			[UIView animateWithDuration:0.33 animations:^(void) {
				_discoveryArticlesView.alpha = 1.0;
				_shadowImgView.alpha = 1.0;
			}];
			
			//[UIView animateWithDuration:0.33 animations:^(void) {
			//	_cardListsButton.hidden = YES;
			//	_holderView.frame = CGRectMake(-270.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
			//}];
			
			[_hud hide:YES];
			_hud = nil;
		}
	}
	else if (resource == _userResource) {
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

-(void)_discoveryReturn:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_holderView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_cardListsButton.hidden = NO;
	}];
}

-(void)_timelineReturn:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_holderView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_cardListsButton.hidden = NO;
	}];
}

-(void)_showArticleComments:(NSNotification *)notification {
	SNArticleCommentsViewController_iPhone *articleCommentsViewController = [[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object] listID:0];
	[self.navigationController pushViewController:articleCommentsViewController animated:YES];
}

-(void)_showArticleDetails:(NSNotification *)notification {
	SNArticleDetailsViewController_iPhone *articleDetailsViewController = [[SNArticleDetailsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object]];
	[self.navigationController pushViewController:articleDetailsViewController animated:YES];
}

-(void)_showArticlePage:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:vo.article_url] title:vo.title];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showArticleSources:(NSNotification *)notification {
	[self.navigationController pushViewController:[[SNArticleSourcesViewController_iPhone alloc] initWithListVO:(SNListVO *)[_popularLists objectAtIndex:0]] animated:YES];
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
		
		//[_subscribedLists removeObjectIdenticalTo:vo];
		
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
		//NSString *msg; 
		
		//if (result == TWTweetComposeViewControllerResultDone)
		//	msg = @"Tweet compostion completed.";
		
		//else if (result == TWTweetComposeViewControllerResultCancelled)
		//	msg = @"Tweet composition canceled.";
		
		
		//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tweet Status" message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		//[alertView show];
		
		[self dismissModalViewControllerAnimated:YES];
	};
}



#pragma mark - TableView DataSource Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([tableView isEqual:_topicsTableView]) {
		return ([_topicsList count]);
		
	} else {
		return ([_popularLists count]);
	}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([tableView isEqual:_topicsTableView]) {
		SNRootTopicViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNRootTopicViewCell_iPhone cellReuseIdentifier]];
		
		if (cell == nil)
			cell = [[SNRootTopicViewCell_iPhone alloc] init];
			
		cell.topicVO = (SNTopicVO *)[_topicsList objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[_subscribedCells addObject:cell];
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (50.0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	if ([tableView isEqual:_popularTableView]) {
		[UIView animateWithDuration:0.33 animations:^(void) {
			_discoveryArticlesView.alpha = 0.0;
			_shadowImgView.alpha = 0.0;
			
//			_discoveryArticlesView.frame = CGRectMake(320.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
//			_shadowView.frame = CGRectMake(320.0, _shadowView.frame.origin.y, _shadowView.frame.size.width, _shadowView.frame.size.height);
			
		} completion:^(BOOL finished) {
			[_articleTimelineView removeFromSuperview];
			_articleTimelineView = nil;
			
			_articleTimelineView = [[SNArticleTimelineView_iPhone alloc] initWithFrame:CGRectMake(276.0, 0.0, 320.0, 480.0) listVO:(SNListVO *)[_popularLists objectAtIndex:indexPath.row]];
			[_holderView addSubview:_articleTimelineView];
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_cardListsButton.hidden = YES;
				_holderView.frame = CGRectMake(-276.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
				
			} completion:^(BOOL finished) {
			}];
		}];
		
	} else if ([tableView isEqual:_topicsTableView]) {
		[UIView animateWithDuration:0.33 animations:^(void) {
			_discoveryArticlesView.alpha = 0.0;
			_shadowImgView.alpha = 0.0;
			
//			_discoveryArticlesView.frame = CGRectMake(320.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
//			_shadowView.frame = CGRectMake(320.0, _shadowView.frame.origin.y, _shadowView.frame.size.width, _shadowView.frame.size.height);
			
		} completion:^(BOOL finished) {
			[_articleTimelineView removeFromSuperview];
			_articleTimelineView = nil;
			
			_articleTimelineView = [[SNArticleTimelineView_iPhone alloc] initWithFrame:CGRectMake(276.0, 0.0, 320.0, 480.0) listVO:(SNListVO *)[_topicsList objectAtIndex:indexPath.row]];
			[_holderView addSubview:_articleTimelineView];
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_cardListsButton.hidden = YES;
				_holderView.frame = CGRectMake(-276.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
				
			} completion:^(BOOL finished) {
			}];
		}];
	}
}

#pragma mark - ScrollView Delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}



@end