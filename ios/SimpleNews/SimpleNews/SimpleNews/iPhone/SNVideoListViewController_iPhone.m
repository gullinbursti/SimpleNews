//
//  SNViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoListViewController_iPhone.h"
#import "SNVideoItemVO.h"

#import "SNVideoItemView_iPhone.h"

@interface SNVideoListViewController_iPhone()
-(NSUInteger)screenNumber;
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_categorySwiped:) name:@"CATEGORY_SWIPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_airplayBack:) name:@"AIRPLAY_BACK" object:nil];
		
		_userInterfaceIdiom = userInterfaceIdiom;
		_videoItems = [NSMutableArray new];
		_itemViews = [NSMutableArray new];
		_isSwiped = NO;
		_isQueued = NO;
		_isFirstScrolled = NO;
		_scrollOffset = 0;
		
		//NSLog(@"USER INTERFACE:[%d]", _userInterfaceIdiom); 0 == iPhone // 1 == iPad
		
		NSString *testVideoItemsPath = [[NSBundle mainBundle] pathForResource:@"video_items" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testVideoItemsPath] options:NSPropertyListImmutable format:nil error:nil];
		
		for (NSDictionary *testVideoItem in plist)
			[_videoItems addObject:[SNVideoItemVO videoItemWithDictionary:testVideoItem]];
	}
	
	return (self);
}

-(void)dealloc {
	[_scrollView release];
	
	[super dealloc];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	NSLog(@"SCREEN:[%d]", [self screenNumber]);
	
	if ([self screenNumber] == 1)
		[self.view setBackgroundColor:[UIColor blackColor]];
	
	else
		[self.view setBackgroundColor:[UIColor greenColor]];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 83.0, self.view.bounds.size.width, self.view.bounds.size.height - 83.0)];
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
	_scrollView.contentOffset = CGPointMake(55.0, 0.0);
	[_holderView addSubview:_scrollView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -_scrollView.bounds.size.height + 55.0, self.view.frame.size.width, _scrollView.bounds.size.height)];
	_refreshHeaderView.delegate = self;
	[_scrollView addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
	
	/*
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 50, 50, 50)] autorelease];
	//MPVolumeView *volumeView = [[[MPVolumeView alloc] init] autorelease];
	[volumeView setShowsVolumeSlider:NO];
	[volumeView sizeToFit];
	[self.view addSubview:volumeView];
	*/
	
	
	int tot = 0;
	for (SNVideoItemVO *vo in _videoItems) {
		SNVideoItemView_iPhone *itemView = [[[SNVideoItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, 55.0 + (150.0 * tot), self.view.bounds.size.width, 150.0) videoItemVO:vo] autorelease];
		[_itemViews addObject:itemView];		
		[_scrollView addSubview:itemView];
		
		//NSLog(@"VIDEO ITEM:[%d] \"%@\"", vo.video_id, vo.video_title);
		tot++;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 55.0 + (150.0 * tot));
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[_holderView addGestureRecognizer:panRecognizer];
	
	_categoryListView = [[SNCategoryListView_iPhone alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_categoryListView];
	
	_airplayListView = [[SNAirplayListView_iPhone alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_airplayListView];
	
	_activeListViewController = [[SNActiveListViewController_iPhone alloc] init];
	[self.view addSubview:_activeListViewController.view];
	
	_airplayButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_airplayButton.frame = CGRectMake(270.0, 443.0, 44.0, 44.0);
	[_airplayButton setBackgroundImage:[[UIImage imageNamed:@"airPlayIconButton_nonActive.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
	[_airplayButton setBackgroundImage:[[UIImage imageNamed:@"airPlayIconButton_active.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
	[_airplayButton addTarget:self action:@selector(_goAirplay) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_airplayButton];
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

/*
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	
	else
	    return (YES);
}
*/


#pragma mark - Navigation
-(void)_goAirplay {
	NSLog(@"GO AIRLPLAY");
	[UIView animateWithDuration:0.33 animations:^(void) {
		_activeListViewController.view.frame = CGRectMake(self.view.bounds.size.width, _activeListViewController.view.frame.origin.y, self.view.bounds.size.width, _activeListViewController.view.frame.size.height);
		_holderView.frame = CGRectMake(self.view.bounds.size.width, _holderView.frame.origin.y, self.view.bounds.size.width, _holderView.frame.size.height);
		_airplayButton.frame = CGRectMake(_airplayButton.frame.origin.x + self.view.bounds.size.width, _airplayButton.frame.origin.y, _airplayButton.frame.size.width, _airplayButton.frame.size.height);
		_airplayListView.frame = CGRectMake(0.0, _airplayListView.frame.origin.y, self.view.bounds.size.width, _airplayListView.frame.size.height);
	}];
}


#pragma mark - Interaction handlers
-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	NSLog(@"SWIPE @:(%f, %d)", translatedPoint.x, abs(translatedPoint.y));
	
	/*
	if (!_isQueued) {
		if ((translatedPoint.x > 10 && translatedPoint.x < 120) && abs(translatedPoint.y) < 30) {
			//_isSwiped = YES;
			if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateRecognized) {
				//_swipePt = [(UIPanGestureRecognizer*)sender translationInView:_holderView];
				_swipePt = [(UIPanGestureRecognizer*)sender locationInView:_holderView];
				
				_swipePt.y = (_scrollView.contentOffset.y + _swipePt.y);
				
				int ind = 0;
				for (SNVideoItemView_iPhone *view in _itemViews) {
					if (CGRectContainsPoint(view.frame, _swipePt)) {
						SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:ind];
						_isQueued = YES;
						_isSwiped = YES;
						NSLog(@"FOUND TOUCH IN:(%@)", vo.video_title);
						
						_queuedItemView = view;
						[UIView animateWithDuration:0.125 animations:^(void) {
							CGRect frame = view.frame;
							frame.origin.x = 64.0;
							view.frame = frame;
						
						} completion:^(BOOL finished) {
								
						}];
					}
					
					ind++;
				}
			}
		}
		
	} else {
		if ((translatedPoint.x < -10 && translatedPoint.x > -120) && abs(translatedPoint.y) < 30) {
			[UIView animateWithDuration:0.125 animations:^(void) {
				CGRect frame = _queuedItemView.frame;
				frame.origin.x = 0.0;
				_queuedItemView.frame = frame;
			
			} completion:^(BOOL finished) {
				_queuedItemView = nil;
				[self performSelector:@selector(_resetSwipe) withObject:nil afterDelay:0.5];
			}];
		}
	}
	*/
	
	
	if (!_isSwiped && !_isQueued) {
		if (translatedPoint.x < -50 && abs(translatedPoint.y) < 30) {
			_isSwiped = YES;
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_activeListViewController.view.frame = CGRectMake(-self.view.frame.size.width, _activeListViewController.view.frame.origin.y, self.view.frame.size.width, _activeListViewController.view.frame.size.height);
				_scrollView.frame = CGRectMake(-_scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
				_airplayButton.frame = CGRectMake(-self.view.frame.size.width + _airplayButton.frame.origin.x, _airplayButton.frame.origin.y, _airplayButton.frame.size.width, _airplayButton.frame.size.height);
				_categoryListView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
			
			} completion:^(BOOL finished) {
				[self _resetToTop];
			}];
		}
	}
}

-(void)_resetSwipe {
	_isQueued = NO;
	_isSwiped = NO;
}



#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	
	SNVideoItemView_iPhone *tappedView;
	
	int ind = 0;
	int offset = 0;
	for (SNVideoItemView_iPhone *view in _itemViews) {
		if ([vo isEqual:view.vo]) {
			tappedView = view;
			[tappedView removeFromSuperview];
			break;
		}
		
		ind++;
	}
	
	//float lastOffset = ((SNVideoItemView_iPhone *)[_itemViews objectAtIndex:[_itemViews count] - 1]).frame.origin.y;
	tappedView.frame = CGRectMake(0.0, 55.0 + ([_itemViews count] * 150), self.view.bounds.size.width, 150.0);
	
	for (int i=ind; i<[_itemViews count]; i++) {
		SNVideoItemView_iPhone *view = (SNVideoItemView_iPhone *)[_itemViews objectAtIndex:i];
		offset = view.frame.origin.y - 150.0;
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			view.frame = CGRectMake(0.0, offset, self.view.bounds.size.width, 150.0);
		
		} completion:^(BOOL finished) {
//			tappedView.frame = CGRectMake(0.0, lastOffset, self.view.bounds.size.width, 150.0);
			[_scrollView addSubview:tappedView];
			
			[_itemViews removeObject:tappedView];
			[_itemViews addObject:tappedView];
		}];
	}
}


-(void)_categorySwiped:(NSNotification *)notification {
	_isSwiped = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_activeListViewController.view.frame = CGRectMake(0.0, _activeListViewController.view.frame.origin.y, self.view.frame.size.width, _activeListViewController.view.frame.size.height);
		_categoryListView.frame = CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
		_airplayButton.frame = CGRectMake(270.0, _airplayButton.frame.origin.y, _airplayButton.frame.size.width, _airplayButton.frame.size.height);
		_scrollView.frame = CGRectMake(0.0, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
	}];
}

-(void)_airplayBack:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_activeListViewController.view.frame = CGRectMake(0.0, _activeListViewController.view.frame.origin.y, self.view.bounds.size.width, _activeListViewController.view.frame.size.height);
		_holderView.frame = CGRectMake(0.0, _holderView.frame.origin.y, self.view.bounds.size.width, _holderView.frame.size.height);
		_airplayButton.frame = CGRectMake(270.0, 443.0, 44.0, 44.0);
		_airplayListView.frame = CGRectMake(-self.view.bounds.size.width, _airplayListView.frame.origin.y, self.view.bounds.size.width, _airplayListView.frame.size.height);
	}];
}




#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//_iphoneVideoView.frame = CGRectMake(0.0, -scrollView.contentOffset.y, scrollView.bounds.size.width, 150.0);
	//CGRect frame = _activeListViewController.view.frame;
	
	//NSLog(@"%f][%f", scrollView.contentOffset.y, _activeListViewController.view.frame.origin.y);
	
	/*
	if (scrollView.contentOffset.y > -48 && scrollView.contentOffset.y < 150) {
		if (_scrollOffset < scrollView.contentOffset.y && _activeListViewController.view.frame.origin.y >= -20.0)
			frame.origin.y--;// -= 0.95;
		
		if (_scrollOffset > scrollView.contentOffset.y && _activeListViewController.view.frame.origin.y <= 30.0)
			frame.origin.y++;// += 0.95;
		
		_scrollOffset = scrollView.contentOffset.y;
		
		_activeListViewController.view.frame = frame;
	}
	*/
	
	if (!_isFirstScrolled && _scrollView.contentOffset.y >= 55) {
		_isFirstScrolled = YES;
	}
	
	if (_isFirstScrolled) {
		if (_scrollView.contentOffset.y > 0 && _scrollView.contentOffset.y < 55)
			_activeListViewController.view.frame = CGRectMake(0.0, -_scrollView.contentOffset.y, self.view.frame.size.width, 138.0);
	}
	
	if (_scrollView.contentOffset.y > 55)
		_activeListViewController.view.frame = CGRectMake(0.0, -55.0, self.view.frame.size.width, 138.0);
	
	if (_scrollView.contentOffset.y < 0) {
		[UIView animateWithDuration:0.125 animations:^(void) {
			_activeListViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 138.0);
		}];
	}
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	//[_airplayButton addTarget:self action:@selector(_goAirplay) forControlEvents:UIControlEventTouchUpInside];
	[_airplayButton removeTarget:self action:@selector(_goAirplay) forControlEvents:UIControlEventTouchUpInside];
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	/*int offset = 75 - (int)scrollView.contentOffset.y % 150;
	
	NSLog(@"OFFSET:[%d]", offset);
	
	if (offset > 0)
		[scrollView setContentOffset:CGPointMake(0.0, (scrollView.contentOffset.y + offset) - 75) animated:YES];
	
	else
		[scrollView setContentOffset:CGPointMake(0.0, (scrollView.contentOffset.y + offset) + 75) animated:YES];
	 */
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	/*int offset = 75 - (int)scrollView.contentOffset.y % 150;
	
	NSLog(@"OFFSET:[%d]", offset);
	
	if (offset > 0)
		[scrollView setContentOffset:CGPointMake(0.0, (scrollView.contentOffset.y + offset) - 75) animated:YES];
	
	else
		[scrollView setContentOffset:CGPointMake(0.0, (scrollView.contentOffset.y + offset) + 75) animated:YES];
	 */
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	//int page = _scrollView.contentOffset.x / 320;
	[_airplayButton addTarget:self action:@selector(_goAirplay) forControlEvents:UIControlEventTouchUpInside];
}



- (void)_reloadData {
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_isReloading = YES;
	
}

- (void)_doneLoadingData {
	
	//  model should call this when its done loading
	_isReloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
	
	[self performSelector:@selector(_resetToTop) withObject:nil afterDelay:0.33];
}


-(void)_resetToTop {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_scrollView.contentOffset = CGPointMake(0.0, 55.0);
		_activeListViewController.view.frame = CGRectMake(_activeListViewController.view.frame.origin.x, -55.0, self.view.frame.size.width, 138.0);
	}];
}


#pragma mark EGORefreshTableHeaderDelegate Methods
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	
	//[self reloadData];
	[self performSelector:@selector(_doneLoadingData) withObject:nil afterDelay:3.0];
	
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return (_isReloading); // should return if data source model is reloading
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}

@end
