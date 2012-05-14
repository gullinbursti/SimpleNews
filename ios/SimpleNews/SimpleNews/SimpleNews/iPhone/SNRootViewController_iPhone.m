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

#import "SNProfileViewController_iPhone.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNBaseRootListViewCell_iPhone.h"
#import "SNAnyListViewCell_iPhone.h"
#import "SNFollowingListViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNArticleListViewController_iPhone.h"
#import "SNDiscoveryArticlesView_iPhone.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNArticleSourcesViewController_iPhone.h"
#import "SNArticleCommentsViewController_iPhone.h"

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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSubscribedList:) name:@"REFRESH_SUBSCRIBED_LIST" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleDetails:) name:@"SHOW_ARTICLE_DETAILS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleSources:) name:@"SHOW_ARTICLE_SOURCES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleComments:) name:@"SHOW_ARTICLE_COMMENTS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_discoveryReturn:) name:@"DISCOVERY_RETURN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_listSubscribe:) name:@"LIST_SUBSCRIBE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_listUnsubscribe:) name:@"LIST_UNSUBSCRIBE" object:nil];
		
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
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	//_holderView = [[UIView alloc] initWithFrame:CGRectMake(-270.0, 0.0, 580.0, self.view.frame.size.height)];
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 580.0, self.view.frame.size.height)];
	_holderView.userInteractionEnabled = YES;
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
	
	_subscribedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 50.0, 248.0, self.view.frame.size.height - 50.0) style:UITableViewStylePlain];
	[_subscribedTableView setBackgroundColor:[UIColor clearColor]];
	_subscribedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_subscribedTableView.rowHeight = 50.0;
	_subscribedTableView.delegate = self;
	_subscribedTableView.dataSource = self;
	_subscribedTableView.scrollsToTop = NO;
	_subscribedTableView.showsVerticalScrollIndicator = NO;
	[_holderView addSubview:_subscribedTableView];
	
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
	
	_subscribedHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_subscribedHeaderView.delegate = self;
	[_subscribedTableView addSubview:_subscribedHeaderView];
	[_subscribedHeaderView refreshLastUpdatedDate];
	
	_popularHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_popularHeaderView.delegate = self;
	[_popularTableView addSubview:_popularHeaderView];
	[_popularHeaderView refreshLastUpdatedDate];
	
	_cardListsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cardListsButton.frame = CGRectMake(276.0, 49.0, 44.0, self.view.frame.size.height - 49.0);
	[_cardListsButton addTarget:self action:@selector(_goCardLists) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_cardListsButton];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_swipeRow:)];
	swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
	swipeRecognizer.delegate = self;
	[_subscribedTableView addGestureRecognizer:swipeRecognizer];
	
}

-(void)viewDidLoad {
	[super viewDidLoad];

//	[UIView animateWithDuration:0.33 animations:^(void) {
//	} completion:nil];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_discoveryArticlesView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		//_discoveryArticlesView.frame = CGRectMake(276.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
		//_shadowView.frame = CGRectMake(256.0, _shadowView.frame.origin.y, _shadowView.frame.size.width, _shadowView.frame.size.height);
		
		_discoveryArticlesView.alpha = 1.0;
		_shadowImgView.alpha = 1.0;
	}];
}


#pragma mark - Navigation
-(void)_goListsToggle {
	_isFollowingList = !_isFollowingList;
	
	_toggleLtImgView.hidden = !_isFollowingList;
	_toggleRtImgView.hidden = _isFollowingList;
	
	_subscribedTableView.hidden = !_isFollowingList;
	_popularTableView.hidden = _isFollowingList;
}

-(void)_goCardLists {
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
		[UIView animateWithDuration:0.33 animations:^(void) {
//			_discoveryArticlesView.frame = CGRectMake(320.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
//			_shadowView.frame = CGRectMake(320.0, _shadowView.frame.origin.y, _shadowView.frame.size.width, _shadowView.frame.size.height);
			
			_discoveryArticlesView.alpha = 0.0;
			_shadowImgView.alpha = 0.0;
			
		}completion:^(BOOL finished) {
			_discoveryArticlesView.hidden = YES;
			SNProfileViewController_iPhone *profileViewController = [[SNProfileViewController_iPhone alloc] init];
			[self.navigationController pushViewController:profileViewController animated:YES];
		}];
	}
}

-(void)_swipeRow:(UIGestureRecognizer *)gestureRecognizer {
	NSLog(@"SWIPE");
	
	//[_subscribedLists removeObjectAtIndex:_swipeIndex];
	[_subscribedTableView reloadData];
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
		_subscribedListsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[_subscribedListsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_subscribedListsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_subscribedListsRequest setDelegate:self];
		[_subscribedListsRequest startAsynchronous];
	}
}

-(void)_discoveryReturn:(NSNotification *)notification {
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


#pragma mark - Gesture Recongnizer Deleagtes
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	CGPoint touchPoint = [touch locationInView:_subscribedTableView];
	_swipeIndex = MIN((int)(touchPoint.y / 50.0), [_subscribedLists count] - 1);

	return (YES);
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

//-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//}
//
//
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//	if ([tableView isEqual:_subscribedTableView]) {
//		if (editingStyle == UITableViewCellEditingStyleDelete) {
//			NSLog(@"indexPath:[%d]", indexPath.row);
//			[_subscribedLists removeObjectAtIndex:2];
//			
//			//[_subscribedLists removeObjectAtIndex:indexPath.row];
//			//[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade]; 
//		}
//	}
//}


#pragma mark - TableView Delegates
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
			[self.navigationController pushViewController:[[SNArticleListViewController_iPhone alloc] initWithListVO:(SNListVO *)[_popularLists objectAtIndex:indexPath.row]] animated:YES];
		}];
		
	} else if ([tableView isEqual:_subscribedTableView]) {
		[UIView animateWithDuration:0.33 animations:^(void) {
			_discoveryArticlesView.alpha = 0.0;
			_shadowImgView.alpha = 0.0;
			
//			_discoveryArticlesView.frame = CGRectMake(320.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
//			_shadowView.frame = CGRectMake(320.0, _shadowView.frame.origin.y, _shadowView.frame.size.width, _shadowView.frame.size.height);
			
		} completion:^(BOOL finished) {
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
					//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
					
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
			
			_shadowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(256.0, 0.0, 30.0, _holderView.frame.size.height)];
			_shadowImgView.image = [UIImage imageNamed:@"shadow.png"];
			//[_shadowImgView setBackgroundColor:[SNAppDelegate snDebugRedColor]];
//			_shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
//			_shadowView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
//			_shadowView.layer.shadowOpacity = 0.5;
//			_shadowView.layer.shouldRasterize = YES;
//			_shadowView.layer.shadowRadius = 8.0;
			_shadowImgView.alpha = 0.0;
			[_holderView addSubview:_shadowImgView];
			
			_discoveryArticlesView = [[SNDiscoveryArticlesView_iPhone alloc] initWithFrame:CGRectMake(276.0, 0.0, 320.0, 480.0) listVO:(SNListVO *)[_popularLists objectAtIndex:0]];
			_discoveryArticlesView.alpha = 1.0;
			[_holderView addSubview:_discoveryArticlesView];
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


-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end