//
//  SNViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNViewController_iPhone.h"
#import "SNVideoItemVO.h"

#import "SNVideoItemViewController.h"

@interface SNViewController_iPhone()
-(NSUInteger)screenNumber;
@end

@implementation SNViewController_iPhone

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
		_userInterfaceIdiom = userInterfaceIdiom;
		_videoItems = [NSMutableArray new];
		_viewControllers = [NSMutableArray new];
		
		//NSLog(@"USER INTERFACE:[%d]", _userInterfaceIdiom); 0 == iPhone // 1 == iPad
		
		NSString *testVideoItemsPath = [[NSBundle mainBundle] pathForResource:@"video_items" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testVideoItemsPath] options:NSPropertyListImmutable format:nil error:nil];
		
		for (NSDictionary *testVideoItem in plist)
			[_videoItems addObject:[SNVideoItemVO videoItemWithDictionary:testVideoItem]];
	}
	
	return (self);
}

-(void)dealloc {
	[_deviceScrollView release];
	
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
		
	
	_deviceScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	_deviceScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_deviceScrollView.opaque = NO;
	_deviceScrollView.scrollsToTop = NO;
	_deviceScrollView.pagingEnabled = NO;
	_deviceScrollView.delegate = self;
	_deviceScrollView.showsHorizontalScrollIndicator = NO;
	_deviceScrollView.showsVerticalScrollIndicator = YES;
	_deviceScrollView.alwaysBounceVertical = YES;
	_deviceScrollView.contentSize = self.view.frame.size;
	[self.view addSubview:_deviceScrollView];
	
	/*
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 50, 50, 50)] autorelease];
	//MPVolumeView *volumeView = [[[MPVolumeView alloc] init] autorelease];
	[volumeView setShowsVolumeSlider:NO];
	[volumeView sizeToFit];
	[self.view addSubview:volumeView];
	*/
	
	
	int tot = 0;
	for (SNVideoItemVO *vo in _videoItems) {
		SNVideoItemViewController *viewController = [[[SNVideoItemViewController alloc] initWithVO:vo] autorelease];
		[_viewControllers addObject:viewController];
		
		CGRect frame = CGRectMake(0.0, 192 * tot, self.view.bounds.size.width, 192);
		viewController.view.frame = frame;
		
		[_deviceScrollView addSubview:viewController.view];
		
		//NSLog(@"VIDEO ITEM:[%d] \"%@\"", vo.video_id, vo.video_title);
		tot++;
	}
	
	_deviceScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 192 * tot);
	
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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	
	else
	    return (YES);
}


#pragma mark - Notification handlers


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_iphoneVideoView.frame = CGRectMake(0.0, -scrollView.contentOffset.y, scrollView.bounds.size.width, 192.0);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	//int page = _scrollView.contentOffset.x / 320;	
}

@end
