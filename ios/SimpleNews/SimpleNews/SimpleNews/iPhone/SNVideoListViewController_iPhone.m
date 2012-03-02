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

#import "SNVideoItemView_iPhone.h"
#import "SNVideoDetailsView_iPhone.h"

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

		_userInterfaceIdiom = userInterfaceIdiom;
		_videoItems = [NSMutableArray new];
		_itemViews = [NSMutableArray new];
		_isCategories = NO;
		_isDetails = NO;
		_isStore = NO;
		_scrollOffset = 0;
		
		//NSLog(@"USER INTERFACE:[%d]", _userInterfaceIdiom); 0 == iPhone // 1 == iPad
		
		NSString *testVideoItemsPath = [[NSBundle mainBundle] pathForResource:@"video_items" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testVideoItemsPath] options:NSPropertyListImmutable format:nil error:nil];
		
		for (NSDictionary *testVideoItem in plist)
			[_videoItems addObject:[SNVideoItemVO videoItemWithDictionary:testVideoItem]];
		
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO_PLAYBACK" object:((SNVideoItemVO *)[_videoItems objectAtIndex:0]).video_url];
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
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
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
	
	int tot = 0;
	for (SNVideoItemVO *vo in _videoItems) {
		SNVideoItemView_iPhone *itemView = [[[SNVideoItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, 200 * tot, self.view.bounds.size.width, 200.0) videoItemVO:vo] autorelease];
		[_itemViews addObject:itemView];		
		[_scrollView addSubview:itemView];
		
		//NSLog(@"VIDEO ITEM:[%d] \"%@\"", vo.video_id, vo.video_title);
		tot++;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 200.0 * tot);
	
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
	
	_videoDetailsView = [[SNVideoDetailsView_iPhone alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_videoDetailsView];
	
	_categoryListView = [[SNCategoryListView_iPhone alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_categoryListView];
	
	_pluginListView = [[SNPluginListView_iPhone alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_pluginListView];
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
		_scrollView.frame = CGRectMake(self.view.bounds.size.width, _scrollView.frame.origin.y, _scrollView.frame.size.width, _holderView.frame.size.height);
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
				_scrollView.frame = CGRectMake(-_scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
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
	holdPt.y = (_scrollView.contentOffset.y + holdPt.y);
	
	int ind = 0;
	for (SNVideoItemView_iPhone *view in _itemViews) {
		if (CGRectContainsPoint(view.frame, holdPt)) {
			SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:ind];
			NSLog(@"FOUND TOUCH IN:(%@)", vo.video_title);
			[view fadeTo:1.0];
		
		} else {
			[view fadeTo:0.5];
		}
		
		ind++;
	}
}



#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	SNVideoItemView_iPhone *tappedView;
	
	int ind = 0;
	for (SNVideoItemView_iPhone *view in _itemViews) {
		if ([vo isEqual:view.vo]) {
			tappedView = view;
			break;
		}
		
		ind++;
	}
	
//	[UIView animateWithDuration:0.33 animations:^(void) {
//		tappedView.frame = CGRectMake(self.view.frame.size.width, tappedView.frame.origin.y, tappedView.frame.size.width, tappedView.frame.size.height);
//	
//	} completion:^(BOOL finished) {
//		[tappedView removeFromSuperview];
//		tappedView.frame = CGRectMake(0.0, [_itemViews count] * 150, self.view.bounds.size.width, 150.0);
//		
//		for (int i=ind; i<[_itemViews count]; i++) {
//			SNVideoItemView_iPhone *view = (SNVideoItemView_iPhone *)[_itemViews objectAtIndex:i];
//			int offset = view.frame.origin.y - 150.0;
//			
//			[UIView animateWithDuration:0.33 animations:^(void) {
//				view.frame = CGRectMake(0.0, offset, self.view.bounds.size.width, 150.0);
//				
//			} completion:^(BOOL finished) {
//				[_scrollView addSubview:tappedView];
//				
//				[_itemViews removeObject:tappedView];
//				[_itemViews addObject:tappedView];
//			}];
//		}
//		
//		[self _resetActiveList];
//		
//		
//		[UIView animateWithDuration:0.125 animations:^(void) {
//			self.view.frame = CGRectMake(0.0, 24.0, self.view.frame.size.width, self.view.frame.size.height);
//			
//		} completion:^(BOOL finished) {
//			if ([[UIScreen screens] count] == 1) {
//				[UIView animateWithDuration:0.25 animations:^(void) {
//					self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
//				}];
//			}
//			
//			[SNAppDelegate playMP3:@"fpo_startVideo"];
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];
//		}];
//	}];
	
	[SNAppDelegate playMP3:@"fpo_tapVideo"];
	[_videoDetailsView changeVideo:vo];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(-_scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_videoDetailsView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
		_isDetails = YES;
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];
	}];
}


-(void)_categorySwiped:(NSNotification *)notification {
	_isCategories = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_categoryListView.frame = CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
		_scrollView.frame = CGRectMake(0.0,  _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
	}];
	
	_scrollView.contentOffset = CGPointMake(0.0, 0.0);
}

-(void)_airplayBack:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(0.0, _holderView.frame.origin.y, _holderView.frame.size.width, _holderView.frame.size.height);
		_pluginListView.frame = CGRectMake(-self.view.bounds.size.width, _pluginListView.frame.origin.y, _pluginListView.frame.size.width, _pluginListView.frame.size.height);
	}];
}


-(void)_videoDuration:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	}];
}


-(void)_detailsReturn:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(0.0, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_videoDetailsView.frame = CGRectMake(self.view.bounds.size.width, _videoDetailsView.frame.origin.y, _videoDetailsView.bounds.size.width, _videoDetailsView.frame.size.height);
	}];
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
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
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


-(void)_resetToTop {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_scrollView.contentOffset = CGPointMake(0.0, 55.0);
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
