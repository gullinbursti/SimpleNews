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
		
		_userInterfaceIdiom = userInterfaceIdiom;
		_videoItems = [NSMutableArray new];
		_itemViews = [NSMutableArray new];
		_isSwiped = NO;
		
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
	
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
	[self.view addSubview:_holderView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 75.0, self.view.bounds.size.width, self.view.bounds.size.height - 75.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = NO;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = self.view.frame.size;
	[_holderView addSubview:_scrollView];
	
	/*
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 50, 50, 50)] autorelease];
	//MPVolumeView *volumeView = [[[MPVolumeView alloc] init] autorelease];
	[volumeView setShowsVolumeSlider:NO];
	[volumeView sizeToFit];
	[self.view addSubview:volumeView];
	*/
	
	
	int tot = 0;
	for (SNVideoItemVO *vo in _videoItems) {
		SNVideoItemView_iPhone *itemView = [[[SNVideoItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, 150.0 * tot, self.view.bounds.size.width, 150.0) videoItemVO:vo] autorelease];
		[_itemViews addObject:itemView];		
		[_scrollView addSubview:itemView];
		
		//NSLog(@"VIDEO ITEM:[%d] \"%@\"", vo.video_id, vo.video_title);
		tot++;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 150.0 * tot);
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[self.view addGestureRecognizer:panRecognizer];
	
	_activeListViewController = [[SNActiveListViewController_iPhone alloc] init];
	[_holderView addSubview:_activeListViewController.view];
	
	
	_categoryListView = [[SNCategoryListView_iPhone alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[_holderView addSubview:_categoryListView];
	
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
		_holderView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
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

-(void)_goSwipe:(id)sender {
	
	if (!_isSwiped) {
		CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
		
		if (translatedPoint.x < -10 && abs(translatedPoint.y) < 10.0) {
			_isSwiped = YES;
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_scrollView.frame = CGRectMake(-_scrollView.frame.size.width, 75.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
				_categoryListView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
			}];
		}
	}
}


#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	
	int ind = 0;
	int offset = 0;
	for (SNVideoItemView_iPhone *view in _itemViews) {
		if ([vo isEqual:view.vo]) {
			[view removeFromSuperview];
			break;
		}
		
		ind++;
	}
	
	for (int i=ind; i<[_itemViews count]; i++) {
		SNVideoItemView_iPhone *view = (SNVideoItemView_iPhone *)[_itemViews objectAtIndex:i];
		offset = view.frame.origin.y - 150.0;
		
		NSLog(@"OFFSET:[%d]", offset);
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			view.frame = CGRectMake(0.0, offset, self.view.bounds.size.width, self.view.bounds.size.height);
		}];
	}
	
	[_itemViews removeObjectAtIndex:ind];
	_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, (150.0 * [_itemViews count]) + 75.0);
}

-(void)_categorySwiped:(NSNotification *)notification {
	_isSwiped = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_categoryListView.frame = CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
		_scrollView.frame = CGRectMake(0.0, 75.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
	}];
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//_iphoneVideoView.frame = CGRectMake(0.0, -scrollView.contentOffset.y, scrollView.bounds.size.width, 150.0);
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
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
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {	
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
}

@end
