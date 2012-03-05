//
//  SNViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//



#import "SNVideoListViewController_iPhone.h"
#import "SNVideoItemVO.h"
#import "SNAppDelegate.h"
#import "SNVideoListHeaderView.h"
#import "SNVideoItemViewCell_iPhone.h"

@interface SNVideoListViewController_iPhone()
-(NSUInteger)screenNumber;
-(void)_resetToTop;
@end

@implementation SNVideoListViewController_iPhone

-(NSUInteger)screenNumber {
	NSUInteger  result      = 1;
	UIWindow    *_window    = nil;
	UIScreen    *_screen    = nil;
	NSArray     *_screens   = nil;
	
	_screens = [UIScreen screens];
	
	if ([_screens count] > 1) {
		_window = [self.view window];
		_screen = [_window screen];
		
		if (_screen) {
			for (int i=0; i<[_screens count]; ++i){
				NSLog(@"TEST SCREEN #%d", i);
				UIScreen *_currentScreen = [_screens objectAtIndex:i];
				
				if (_currentScreen == _screen)
					result = i + 1;
			}
		}
	}
	
	return (result);
}


-(id)initWithUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_categorySwiped:) name:@"CATEGORY_SWIPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_airplayBack:) name:@"AIRPLAY_BACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_detailsReturn:) name:@"DETAILS_RETURN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoDuration:) name:@"VIDEO_DURATION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_nextVideo:) name:@"NEXT_VIDEO" object:nil];

		_userInterfaceIdiom = userInterfaceIdiom;
		_videoItems = [NSMutableArray new];
		_isCategories = NO;
		_isDetails = NO;
		_isStore = NO;
		_scrollOffset = 0;
		_playingIndex = 0;
		
		//NSLog(@"USER INTERFACE:[%d]", _userInterfaceIdiom); 0 == iPhone // 1 == iPad
		
		NSString *testVideoItemsPath = [[NSBundle mainBundle] pathForResource:@"video_items" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testVideoItemsPath] options:NSPropertyListImmutable format:nil error:nil];
		
		for (NSDictionary *testVideoItem in plist)
			[_videoItems addObject:[SNVideoItemVO videoItemWithDictionary:testVideoItem]];
		
		
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO_PLAYBACK" object:((SNVideoItemVO *)[_videoItems objectAtIndex:0]).video_url];
	}
	
	return (self);
}

-(void)dealloc {
	[_tableView release];
	
	[super dealloc];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSLog(@"ORIENTATION:[%d]", interfaceOrientation);
	
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ORIENTED_PORTRAIT" object:nil];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_categoryListView.frame = CGRectMake(self.view.frame.size.width, 0.0, _categoryListView.frame.size.width, _categoryListView.frame.size.height);
			_tableView.frame = CGRectMake(-self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
			_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
			_isDetails = YES;
			
		} completion:nil];
		
	} else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ORIENTED_LANDSCAPE" object:nil];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_categoryListView.frame = CGRectMake(self.view.frame.size.width + 200, 0.0, _categoryListView.frame.size.width, _categoryListView.frame.size.height);
			_tableView.frame = CGRectMake(-self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
			_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
			_isDetails = YES;
			
		} completion:nil];
	}
	
	
	return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	NSLog(@"SCREEN:[%d]", [self screenNumber]);
	
	if ([self screenNumber] == 1)
		[self.view setBackgroundColor:[UIColor blackColor]];
	
	else
		[self.view setBackgroundColor:[UIColor greenColor]];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
	[self.view addSubview:_holderView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(-self.view.bounds.size.width, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - _holderView.frame.origin.y) style:UITableViewStylePlain];
	_tableView.rowHeight = 164.0;
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.separatorColor = [UIColor clearColor];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.scrollsToTop = NO;
	_tableView.pagingEnabled = NO;
	_tableView.showsHorizontalScrollIndicator = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.alwaysBounceVertical = NO;
	_tableView.contentSize = self.view.frame.size;
	_tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
	[self.view addSubview:_tableView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -_tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height)];
	_refreshHeaderView.delegate = self;
	[_tableView addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
	
	int tot = 0;
	for (SNVideoItemVO *vo in _videoItems)
		tot++;
	
	_tableView.contentSize = CGSizeMake(self.view.frame.size.width, 200.0 * tot);
	
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
	
	_playingListViewController = [[SNPlayingListViewController_iPhone alloc] initWithVideos:_videoItems];
	_playingListViewController.view.frame = CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:_playingListViewController.view];
	
	_categoryListView = [[SNCategoryListView_iPhone alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_categoryListView];
	
	_pluginListView = [[SNPluginListView_iPhone alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_pluginListView];
	
	
	[_playingListViewController offsetAtIndex:0];
	SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:0];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:vo];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_tableView.frame = CGRectMake(-self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
		_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
		_isDetails = YES;
		
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];
	}];
	
	
	
	
	
	
//	MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(280.0, 460.0, 40.0, 20.0)];
//	[volumeView setShowsVolumeSlider:NO];
//	[volumeView sizeToFit];
//	[self.view addSubview:volumeView];
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
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_holderView.frame = CGRectMake(0.0, _holderView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - _holderView.frame.origin.y);
	}];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
-(void)_goPlugins {
	NSLog(@"GO PLUGINS");
	[UIView animateWithDuration:0.33 animations:^(void) {
		_tableView.frame = CGRectMake(self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
		_pluginListView.frame = CGRectMake(0.0, _pluginListView.frame.origin.y, self.view.bounds.size.width, _pluginListView.frame.size.height);
	}];
}


#pragma mark - Interaction handlers
-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	NSLog(@"SWIPE @:(%f, %d)", translatedPoint.x, abs(translatedPoint.y));
	
	
	if (!_isCategories) {
		if (translatedPoint.x < -20 && abs(translatedPoint.y) < 30) {
			[UIView animateWithDuration:0.33 animations:^(void) {
				_tableView.frame = CGRectMake(-_tableView.frame.size.width, 0.0, _tableView.frame.size.width, _tableView.frame.size.height);
				_categoryListView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
				_isCategories = YES;
			} completion:^(BOOL finished) {
				[self _resetToTop];
			}];
		}
		
		if (translatedPoint.x > 20 && abs(translatedPoint.y) < 20)
			[self _goPlugins];
	}
}

-(void)_goLongPress:(id)sender {
	CGPoint holdPt = [(UIPanGestureRecognizer*)sender locationInView:_holderView];
	holdPt.y = (_tableView.contentOffset.y + holdPt.y);
}



#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
}


-(void)_categorySwiped:(NSNotification *)notification {
	_isCategories = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_categoryListView.frame = CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
		_tableView.frame = CGRectMake(0.0, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
	}];
	
	_tableView.contentOffset = CGPointMake(0.0, 0.0);
}

-(void)_airplayBack:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_tableView.frame = CGRectMake(0.0, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
		_pluginListView.frame = CGRectMake(-self.view.bounds.size.width, _pluginListView.frame.origin.y, _pluginListView.frame.size.width, _pluginListView.frame.size.height);
	}];
}


-(void)_videoDuration:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	}];
}

-(void)_nextVideo:(NSNotification *)notification {
	_playingIndex++;
	
	if (_playingIndex == [_videoItems count])
		_playingIndex = 0;
	
	[_playingListViewController offsetAtIndex:_playingIndex];
	
	SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:_playingIndex];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:vo];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];
}


-(void)_detailsReturn:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_tableView.frame = CGRectMake(0.0, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
		_playingListViewController.view.frame = CGRectMake(self.view.bounds.size.width, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
	}];
}




#pragma mark - TableView Data Source Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_videoItems count]);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNVideoItemViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNVideoItemViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[[SNVideoItemViewCell_iPhone alloc] init] autorelease];
	
	cell.vo = [_videoItems objectAtIndex:indexPath.section];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}



#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (34.0);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (166.0);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	SNVideoListHeaderView *headerView = [[[SNVideoListHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 34.0)] autorelease];
	headerView.vo = (SNVideoItemVO *)[_videoItems objectAtIndex:section];
	
	return (headerView);
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[SNAppDelegate playMP3:@"fpo_tapVideo"];
	
	[((SNVideoItemViewCell_iPhone *)[tableView cellForRowAtIndexPath:indexPath]) setSelected:YES animated:NO];
	
	SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:indexPath.section];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:vo];
	
	_playingIndex = indexPath.section;
	[_playingListViewController offsetAtIndex:_playingIndex];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_tableView.frame = CGRectMake(-self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
		_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
		_isDetails = YES;
		
	} completion:^(BOOL finished) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];
	}];
	
	//[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:_tableView];
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:_tableView];
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
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}


-(void)_resetToTop {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tableView.contentOffset = CGPointMake(0.0, 55.0);
	}];
}


#pragma mark EGORefreshTableHeaderDelegate Methods
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	
	//[self reloadData];
	[self performSelector:@selector(_doneLoadingData) withObject:nil afterDelay:1.33];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return (_isReloading); // should return if data source model is reloading
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}

@end
