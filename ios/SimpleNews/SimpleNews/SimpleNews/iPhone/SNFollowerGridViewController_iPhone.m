//
//  SNFollowerGridViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFollowerGridViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNFollowerVO.h"
#import "SNFollowerGridItemView_iPhone.h"
#import "SNArticleListViewController_iPhone.h"

@interface SNFollowerGridViewController_iPhone()
-(void)_resetToTop;
@end

@implementation SNFollowerGridViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_splashDismissed:) name:@"SPLASH_DISMISSED" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_followerTapped:) name:@"FOLLOWER_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showNowPlaying:) name:@"SHOW_NOW_PLAYING" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_optionsReturn:) name:@"OPTIONS_RETURN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_articlesReturn:) name:@"ARTICLES_RETURN" object:nil];
				
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchCanceled:) name:@"SEARCH_CANCELED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchEntered:) name:@"SEARCH_ENTERED" object:nil];
		
		_followers = [NSMutableArray new];
		_itemViews = [NSMutableArray new];
		_selectedVOs = [NSMutableArray new];
		_isDetails = NO;
		_isOptions = NO;
		_isArticles = NO;
		
		_totSelected = 0;
		_selectedFollowers = @"";
		
		_followersRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Followers.php"]]] retain];
		[_followersRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
		[_followersRequest setTimeOutSeconds:30];
		[_followersRequest setDelegate:self];
		[_followersRequest startAsynchronous];
		
		
		//NSLog(@"USER INTERFACE:[%d]", _userInterfaceIdiom); 0 == iPhone // 1 == iPad
	}
	
	return (self);
}

-(void)dealloc {
	[_scrollView release];
	[_holderView release];
	[_itemViews release];
	[_followers release];
	[_headerView release];
	[_optionsListView release];
	[_refreshHeaderView release];
	[_followersRequest release];
	
	[super dealloc];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


/*
 -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 NSLog(@"ORIENTATION:[%d]", interfaceOrientation);
 
 
 if (interfaceOrientation == UIInterfaceOrientationPortrait) {
 [[NSNotificationCenter defaultCenter] postNotificationName:@"ORIENTED_PORTRAIT" object:nil];
 
 [UIView animateWithDuration:0.33 animations:^(void) {
 _tableView.frame = CGRectMake(-self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
 _playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
 _isDetails = YES;
 
 } completion:nil];
 
 } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
 [[NSNotificationCenter defaultCenter] postNotificationName:@"ORIENTED_LANDSCAPE" object:nil];
 
 [UIView animateWithDuration:0.33 animations:^(void) {
 _tableView.frame = CGRectMake(-self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
 _playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
 _isDetails = YES;
 
 } completion:nil];
 }
 
 
 return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
 }
 */

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	bgImgView.image = [UIImage imageNamed:@"gridBackground.jpg"];
	[self.view addSubview:bgImgView];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
	[self.view addSubview:_holderView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - _holderView.frame.origin.y)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = self.view.frame.size;
	_scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
	[_holderView addSubview:_scrollView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -_scrollView.bounds.size.height, self.view.frame.size.width, _scrollView.bounds.size.height)];
	_refreshHeaderView.delegate = self;
	[_scrollView addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
	
	_headerView = [[SNFollowerGridHeaderView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 50.0)];
	[_scrollView addSubview:_headerView];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[_holderView addGestureRecognizer:panRecognizer];
	
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	[longPressRecognizer setNumberOfTouchesRequired:1];
	[longPressRecognizer setMinimumPressDuration:0.5];
	[longPressRecognizer setDelegate:self];
	[_holderView addGestureRecognizer:longPressRecognizer];
	
	_optionsListView = [[SNOptionsListView_iPhone alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	_optionsListView.hidden = YES;
	[self.view addSubview:_optionsListView];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
-(void)_goOptions {
	_isOptions = YES;
	_optionsListView.hidden = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		//_scrollView.frame = CGRectMake(self.view.bounds.size.width, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_optionsListView.frame = CGRectMake(0.0, _optionsListView.frame.origin.y, self.view.bounds.size.width, _optionsListView.frame.size.height);
	}];
}

-(void)_goArticles {
	[SNAppDelegate playMP3:@"fpo_tapVideo"];
	
	_isArticles = YES;
	
	SNArticleListViewController_iPhone *articleListViewController;
	
	if (_totSelected == 0)
		articleListViewController = [[[SNArticleListViewController_iPhone alloc] initAsMostRecent] autorelease];
	
	else
		articleListViewController = [[[SNArticleListViewController_iPhone alloc] init] autorelease];
	
	
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:articleListViewController] autorelease];
	
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:articleListViewController animated:YES];	
	
	
	//[self.navigationController pushViewController:[[[SNChannelListViewController_iPhone alloc] init] autorelease] animated:YES];
}


#pragma mark - Interaction handlers
-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
	NSLog(@"SWIPE @:(%f)", translatedPoint.x);
	
	if (!_isDetails && !_isOptions) {	
		//		if (translatedPoint.x > 20.0 && abs(translatedPoint.y) < 20) {
		//			[self _goOptions];
		//		}
		
		if (!_isArticles && (translatedPoint.x < -20.0 && abs(translatedPoint.y) < 20)) {
			[self _goArticles];
		}
	}
}

-(void)_goLongPress:(id)sender {
	CGPoint holdPt = [(UIPanGestureRecognizer *)sender locationInView:_holderView];
	holdPt.y = (_scrollView.contentOffset.y + holdPt.y);
}

-(void)_resetToTop {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_scrollView.contentOffset = CGPointMake(0.0, 0.0);
	}];
}




#pragma mark - Notification handlers
-(void)_showNowPlaying:(NSNotification *)notification {
	[self _goArticles];
}

-(void)_searchEntered:(NSNotification *)notification {
	NSLog(@"SEARCH ENTERED");
	
	[self _resetToTop];
}

-(void)_searchCanceled:(NSNotification *)notificiation {
	NSLog(@"SEARCH CANCELED");
	
	[self _resetToTop];
}

-(void)_optionsReturn:(NSNotification *)notification {
	_isOptions = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_optionsListView.frame = CGRectMake(-self.view.bounds.size.width, _optionsListView.frame.origin.y, _optionsListView.frame.size.width, _optionsListView.frame.size.height);
	} completion:^(BOOL finished) {
		_optionsListView.hidden = YES;
	}];
}

-(void)_articlesReturn:(NSNotification *)notification {
	_isArticles = NO;
}


-(void)_splashDismissed:(NSNotification *)notification {
	[self _goArticles];
}

-(void)_followerTapped:(NSNotification *)notification {
	SNFollowerVO *vo = (SNFollowerVO *)[notification object];
	if (![_selectedVOs containsObject:vo]) {
		[_selectedVOs addObject:vo];
	}
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:_scrollView];
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}



-(void)_reloadData {
	_isReloading = YES;	
}

-(void)_doneLoadingData {
	_isReloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}



#pragma mark EGORefreshTableHeaderDelegate Methods
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	
	//[self reloadData];
	[self performSelector:@selector(_doneLoadingData) withObject:nil afterDelay:1.33];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return (_isReloading); // should return if data source model is reloading
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date]; // should return date data source was last changed
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNFollowerGridViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedFollowers = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *followerList = [NSMutableArray array];
			_itemViews = [NSMutableArray new];
			
			SNFollowerGridItemView_iPhone *followerItemView = [[[SNFollowerGridItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, 50.0, 80.0, 80.0) followerVO:nil] autorelease];
			[_itemViews addObject:followerItemView];
			
			int tot = 1;
			for (NSDictionary *serverFollower in parsedFollowers) {
				SNFollowerVO *vo = [SNFollowerVO followerWithDictionary:serverFollower];
				
				NSLog(@"FOLLOWER \"@%@\" %d", vo.handle, vo.totalArticles);
				
				if (vo != nil)
					[followerList addObject:vo];
				
				SNFollowerGridItemView_iPhone *channelItemView = [[[SNFollowerGridItemView_iPhone alloc] initWithFrame:CGRectMake(80.0 * (tot % 4), 50.0 + (80.0 * (int)(tot / 4)), 80.0, 80.0) followerVO:vo] autorelease];
				[_itemViews addObject:channelItemView];
				tot++;
			}
			
			_followers = [followerList retain];
			[followerList release];
			_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 50.0 + ((ceil(tot / 4) + 1) * 80.0));
			
			for (SNFollowerGridItemView_iPhone *followerItemView in _itemViews)
				[_scrollView addSubview:followerItemView];
		}			
		
		//[self _goArticles];
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	
	if (request == _followersRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}

@end
