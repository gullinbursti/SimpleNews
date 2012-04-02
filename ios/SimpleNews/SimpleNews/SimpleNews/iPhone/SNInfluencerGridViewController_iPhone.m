//
//  SNInfluencerGridViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNInfluencerGridViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNTagVO.h"
#import "SNInfluencerVO.h"
#import "SNCategoryViewCell_iPhone.h"
#import "SNArticleListViewController_iPhone.h"
#import "SNOptionsViewController_iPhone.h"
#import "SNInfluencerProfileViewController_iPhone.h"

@interface SNInfluencerGridViewController_iPhone()
-(void)_resetToTop;
@end

@implementation SNInfluencerGridViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_splashDismissed:) name:@"SPLASH_DISMISSED" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_influencerTapped:) name:@"INFLUENCER_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_recentTapped:) name:@"RECENT_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_influencerClosed:) name:@"INFLUENCER_CLOSED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_queueInfluencer:) name:@"QUEUE_INFLUENCER" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_influencerArticles:) name:@"INFLUENCER_ARTICLES" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_optionsReturn:) name:@"OPTIONS_RETURN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_articlesReturn:) name:@"ARTICLES_RETURN" object:nil];
				
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchCanceled:) name:@"SEARCH_CANCELED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchEntered:) name:@"SEARCH_ENTERED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tagSearch:) name:@"TAG_SEARCH" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showNowPlaying:) name:@"SHOW_NOW_PLAYING" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showOptions:) name:@"SHOW_OPTIONS" object:nil];
		
		_influencers = [NSMutableArray new];
		_itemViews = [NSMutableArray new];
		_tags = [NSMutableArray new];
		_categories = [NSMutableArray new];
		_categorizedInfluencers = [NSMutableArray new];
		_isDetails = NO;
		_isOptions = NO;
		_isArticles = NO;
		_isFirst = YES;
		
		_recentRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Influencers.php"]]] retain];
		[_recentRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_recentRequest setTimeOutSeconds:30];
		[_recentRequest setDelegate:self];
		[_recentRequest startAsynchronous];
		
		_tagsRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Tags.php"]]] retain];
		[_tagsRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
		[_tagsRequest setTimeOutSeconds:30];
		[_tagsRequest setDelegate:self];
		[_tagsRequest startAsynchronous];
		
		_influencersRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Influencers.php"]]] retain];
		[_influencersRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
		[_influencersRequest setTimeOutSeconds:30];
		[_influencersRequest setDelegate:self];
		
		
		//NSLog(@"USER INTERFACE:[%d]", _userInterfaceIdiom); 0 == iPhone // 1 == iPad
	}
	
	return (self);
}

-(void)dealloc {
	[_scrollView release];
	[_holderView release];
	[_itemViews release];
	[_influencers release];
	[_headerView release];
	[_influencersRequest release];
	
	[super dealloc];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	bgImgView.image = [UIImage imageNamed:@"background.jpg"];
	[self.view addSubview:bgImgView];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 56.0, self.view.bounds.size.width, self.view.bounds.size.height - 56.0)];
	[self.view addSubview:_holderView];
	
	_headerView = [[SNInfluencerGridHeaderView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 56.0)];
	[self.view addSubview:_headerView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 56.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 170.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.allowsSelection = NO;
	_tableView.pagingEnabled = NO;
	_tableView.opaque = NO;
	_tableView.scrollsToTop = NO;
	_tableView.showsHorizontalScrollIndicator = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.alwaysBounceVertical = NO;
	[_holderView addSubview:_tableView];
		
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	[longPressRecognizer setNumberOfTouchesRequired:1];
	[longPressRecognizer setMinimumPressDuration:0.5];
	[longPressRecognizer setDelegate:self];
	//[_holderView addGestureRecognizer:longPressRecognizer];
	
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
-(void)_goArticles {
	//[SNAppDelegate playMP3:@"fpo_tapVideo"];
	
	_isArticles = YES;
	
	SNArticleListViewController_iPhone *articleListViewController;
	
	if (_isFirst || [[SNAppDelegate subscribedInfluencers] isEqualToString:@""]) {
		_isFirst = NO;
		articleListViewController = [[[SNArticleListViewController_iPhone alloc] initAsMostRecent] autorelease];
	
	} else
		articleListViewController = [[[SNArticleListViewController_iPhone alloc] initWithInfluencers] autorelease];
	
	
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:articleListViewController] autorelease];
	
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:articleListViewController animated:YES];	
}

-(void)_goArticlesWithTag:(id)tag_id {
	SNArticleListViewController_iPhone *articleListViewController = [[[SNArticleListViewController_iPhone alloc] initWithTag:[tag_id intValue]] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:articleListViewController] autorelease];
		
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:articleListViewController animated:YES];	
}



#pragma mark - Interaction handlers
-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
	NSLog(@"SWIPE @:(%f)", translatedPoint.x);
	
	if (!_isDetails && !_isOptions) {	
		if (!_isArticles && (translatedPoint.x < -20.0 && abs(translatedPoint.y) < 20))
			[self _goArticles];
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

-(void)_showOptions:(NSNotification *)notification {
	_isOptions = YES;
	
	[self.navigationController pushViewController:[[[SNOptionsViewController_iPhone alloc] init] autorelease] animated:YES];
}


-(void)_searchEntered:(NSNotification *)notification {
	NSLog(@"SEARCH ENTERED");
	
	[self _resetToTop];
	NSMutableArray *searchTags = [[NSMutableArray new] autorelease];
	NSArray *enteredTags = [((NSString *)[notification object]) componentsSeparatedByString:@" "];
	
	for (NSString *enteredTag in enteredTags) {
		for (SNTagVO *vo in _tags) {
			if ([[vo.title lowercaseString] isEqualToString:[enteredTag lowercaseString]])
				[searchTags addObject:[NSNumber numberWithInt:vo.tag_id]];
		}
	}
	
	NSString *tagIDs = @"";
	
	for (NSNumber *tagID in searchTags)
		tagIDs = [tagIDs stringByAppendingFormat:@"|%d", [tagID intValue]];
	
	tagIDs = [tagIDs substringFromIndex:1];
	
	SNArticleListViewController_iPhone *articleListViewController = [[[SNArticleListViewController_iPhone alloc] initWithTags:tagIDs] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:articleListViewController] autorelease];
	
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:articleListViewController animated:YES];
}

-(void)_searchCanceled:(NSNotification *)notificiation {
	NSLog(@"SEARCH CANCELED");
	
	[self _resetToTop];
}

-(void)_tagSearch:(NSNotification *)notification {
	[self performSelector:@selector(_goArticlesWithTag:) withObject:[notification object] afterDelay:0.5];
}

-(void)_optionsReturn:(NSNotification *)notification {
	_isOptions = NO;
}

-(void)_articlesReturn:(NSNotification *)notification {
	_isArticles = NO;
}


-(void)_splashDismissed:(NSNotification *)notification {
	[self _goArticles];
}

-(void)_influencerTapped:(NSNotification *)notification {
	NSLog(@"INFLUENCER TAPPED");
	SNInfluencerVO *vo = (SNInfluencerVO *)[notification object];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INFLUENCER_ARTICLES" object:vo];
	
	SNInfluencerProfileViewController_iPhone *influencerProfileViewController = [[[SNInfluencerProfileViewController_iPhone alloc] initWithInfluencerVO:vo] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:influencerProfileViewController] autorelease];
	
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:influencerProfileViewController animated:YES];
}

-(void)_influencerClosed:(NSNotification *)notification {
	SNInfluencerVO *vo = (SNInfluencerVO *)[notification object];
	
	for (SNBaseInfluencerGridItemView_iPhone *view in _itemViews) {
		if ([vo isEqual:view.vo])
			[view toggleSelected:NO];
	}
}

-(void)_recentTapped:(NSNotification *)notification {
	for (SNBaseInfluencerGridItemView_iPhone *view in _itemViews)
		[view toggleSelected:NO];
	
	SNBaseInfluencerGridItemView_iPhone *view = (SNBaseInfluencerGridItemView_iPhone *)[_itemViews objectAtIndex:0];
	[view toggleSelected:YES];
	
	[SNAppDelegate writeInfluencers:@""];
}

-(void)_queueInfluencer:(NSNotification *)notification {
	SNInfluencerVO *vo = (SNInfluencerVO *)[notification object];
	
	SNBaseInfluencerGridItemView_iPhone *view = (SNBaseInfluencerGridItemView_iPhone *)[_itemViews objectAtIndex:0];
	[view toggleSelected:NO];
	
	if ([[SNAppDelegate subscribedInfluencers] length] == 0)
		[SNAppDelegate writeInfluencers:[NSString stringWithFormat:@"%d", vo.influencer_id]];
	
	else
		[SNAppDelegate writeInfluencers:[[SNAppDelegate subscribedInfluencers] stringByAppendingFormat:@"|%d", vo.influencer_id]];
}

-(void)_influencerArticles:(NSNotification *)notification {
	SNInfluencerVO *vo = (SNInfluencerVO *)[notification object];
	
	SNBaseInfluencerGridItemView_iPhone *view = (SNBaseInfluencerGridItemView_iPhone *)[_itemViews objectAtIndex:0];
	[view toggleSelected:NO];
	
	[SNAppDelegate writeInfluencers:[NSString stringWithFormat:@"%d", vo.influencer_id]];
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"numberOfSectionsInTableView:[%d]", [_categorizedInfluencers count]);
	return ([_categorizedInfluencers count]);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	SNCategoryViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNCategoryViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[[SNCategoryViewCell_iPhone alloc] init] autorelease];
	
	cell.influencers = [_categorizedInfluencers objectAtIndex:indexPath.section];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (170.0);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (31.0);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	//NSLog(@"viewForHeaderInSection:[%@]", [_categories objectAtIndex:section]);
	
	UIView *sectionHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _tableView.frame.size.width, 31.0)] autorelease];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 29.0)] autorelease];
	bgImgView.image = [UIImage imageNamed:@"peopleTableHeader.png"];
	[sectionHeaderView addSubview:bgImgView];
	
	UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 296.0, 31.0)] autorelease];
	titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:11];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.05];
	titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	titleLabel.text = [_categories objectAtIndex:section];
	[sectionHeaderView addSubview:titleLabel];
	
	return (sectionHeaderView);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (nil);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
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


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNInfluencerGridViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	
	if ([request isEqual:_influencersRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSArray *parsedInfluencers = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *list = [NSMutableArray array];
				
				for (NSDictionary *serverCategory in parsedInfluencers) {
					//NSLog(@"\n\n\nCATEGORY \"%@\"", [serverCategory objectForKey:@"title"]);
					NSMutableArray *influencerList = [NSMutableArray array];
					[_categories addObject:[serverCategory objectForKey:@"title"]];
					
					for (NSDictionary *serverInfluencer in [serverCategory objectForKey:@"influencers"]) {
						SNInfluencerVO *vo = [SNInfluencerVO influencerWithDictionary:serverInfluencer];
						//NSLog(@"INFLUENCER \"@%@\" %d", vo.handle, vo.totalArticles);
						
						if (vo != nil)
							[influencerList addObject:vo];
					}
					
					[list addObject:influencerList];
				}
				
				_categorizedInfluencers = [list retain];
				[_tableView reloadData];
			}
		}
	
	} else if ([request isEqual:_tagsRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSArray *parsedTags = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *tagList = [NSMutableArray array];
				
				int tot = 0;
				for (NSDictionary *serverTag in parsedTags) {
					SNTagVO *vo = [SNTagVO tagWithDictionary:serverTag];
					
					if (vo != nil)
						[tagList addObject:vo];
					
					tot++;
				}
				
				_tags = [tagList retain];
			}
		}
	
	} else if ([request isEqual:_recentRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSArray *parsedRecents = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *recentList = [NSMutableArray array];
				_itemViews = [NSMutableArray new];
				
				for (NSDictionary *serverRecent in parsedRecents)
					[recentList addObject:[serverRecent objectForKey:@"avatar_url"]];
				
				_recentInfluencersView = [[SNRecentInfluencersView_iPhone alloc] initWithFrame:CGRectMake(0.0, 50.0, 80.0, 80.0) avatarURLs:[NSArray arrayWithObjects:[recentList objectAtIndex:0], [recentList objectAtIndex:1], [recentList objectAtIndex:2], [recentList objectAtIndex:3], nil]];
				
				[_itemViews addObject:_recentInfluencersView];
				[_scrollView addSubview:_recentInfluencersView];
			}
		}
		
		[_influencersRequest startAsynchronous];
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	
	if (request == _influencersRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}

@end
