//
//  SNDiscoveryListView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNDiscoveryListView_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNNavRandomBtnView.h"
#import "SNAppDelegate.h"
#import "SNDiscoveryItemView_iPhone.h"

#import "MBLResourceLoader.h"

@interface SNDiscoveryListView_iPhone() <MBLResourceObserverProtocol>
- (void)_retrieveArticleList;
- (void)_refreshArticleList;
@property(nonatomic, strong) MBLAsyncResource *articleListResource;
@property(nonatomic, strong) MBLAsyncResource *refreshListResource;
@end

@implementation SNDiscoveryListView_iPhone

@synthesize articleListResource = _articleListResource;
@synthesize refreshListResource = _refreshListResource;
@synthesize overlayView = _overlayView;

- (id)initWithHeaderTitle:(NSString *)title isTop10:(BOOL)top10 {
	if ((self = [super init])) {
		// Seems like this shouldn't be necessary because a new object won't be observing any notifications
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FULLSCREEN_MEDIA" object:nil];	
		
		self.title = title;
		self.delegate = self;
		_isTop10List = top10;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Background needs to be behind the scroll view
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	bgImgView.image = [UIImage imageNamed:@"timelineDiscoverBackground.png"];
	[self.view addSubview:bgImgView];
	[self.view sendSubviewToBack:bgImgView];
	self.scrollView.opaque = NO;
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:self.title];
	[self.view addSubview:headerView];
	
	_listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[_listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:_listBtnView];
	
	SNNavRandomBtnView *rndBtnView = [[SNNavRandomBtnView alloc] initWithFrame:CGRectMake(273.0, 0.0, 44.0, 44.0)];
	[[rndBtnView btn] addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:rndBtnView];
	
	_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 40.0, self.view.frame.size.height - 44)];
	[self.view addSubview:_overlayView];
	
	// @revisit Move to -viewWillAppear:
	[self _retrieveArticleList];
}

- (void)dealloc {
	if (_articleListResource != nil) {
		[_articleListResource unsubscribe:self];
		_articleListResource = nil;
	}
}

- (void)setArticleListResource:(MBLAsyncResource *)articleListResource {
	if (_articleListResource != nil) {
		[_articleListResource unsubscribe:self];
		_articleListResource = nil;
	}
	
	_articleListResource = articleListResource;
	
	if (_articleListResource != nil)
		[_articleListResource subscribe:self];
}

- (void)setRefreshListResource:(MBLAsyncResource *)refreshListResource {
	if (_refreshListResource != nil) {
		[_refreshListResource unsubscribe:self];
		_refreshListResource = nil;
	}
	
	_refreshListResource = refreshListResource;
	
	if (_refreshListResource != nil)
		[_refreshListResource subscribe:self];
}

- (void)_retrieveArticleList {
	if (_articleListResource == nil) {
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.taskInProgress = YES;
		_progressHUD.graceTime = 3.0;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		
		if (_isTop10List)
			[formValues setObject:[NSString stringWithFormat:@"%d", 14] forKey:@"action"];
		
		else
			[formValues setObject:[NSString stringWithFormat:@"%d", 10] forKey:@"action"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute expiration for now
	}
}

- (void)_refreshArticleList {
	_refreshListResource = nil;
	
	if (_refreshListResource == nil) {
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.taskInProgress = YES;
		_progressHUD.graceTime = 3.0;
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		
		if (_isTop10List)
			[formValues setObject:[NSString stringWithFormat:@"%d", 15] forKey:@"action"];
		
		else
			[formValues setObject:[NSString stringWithFormat:@"%d", 16] forKey:@"action"];
			
		[formValues setObject:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.refreshListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute expiration for now
	}
}

- (void)interactionEnabled:(BOOL)isEnabled {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FULLSCREEN_MEDIA" object:nil];
	
	if (isEnabled) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fullscreenMedia:) name:@"FULLSCREEN_MEDIA" object:nil];
		[[_listBtnView btn] removeTarget:self action:@selector(_goShow) forControlEvents:UIControlEventTouchUpInside];
		[[_listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		
	} else {
		[[_listBtnView btn] removeTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[[_listBtnView btn] addTarget:self action:@selector(_goShow) forControlEvents:UIControlEventTouchUpInside];
	}
	
	self.scrollView.userInteractionEnabled = isEnabled;
}

#pragma mark - Page View Delegate

- (MBLPageItemViewController *)makeItemViewControllerForPageViewController:(MBLPageViewController *)pageViewController
{
	SNDiscoveryItemView_iPhone *itemViewController = [[SNDiscoveryItemView_iPhone alloc] init];
	return itemViewController;
}

- (void)pageViewController:(MBLPageViewController *)pageViewController selectionDidChangeToIndex:(NSUInteger)index
{
	[_paginationView changeToPage:index];
}

#pragma mark - Navigation

- (void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DISCOVERY_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
}

- (void)_goShow {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_DISCOVERY" object:nil];
}

- (void)_goRefresh {
	[self _refreshArticleList];
}

#pragma mark - Notification handlers

-(void)_fullscreenMedia:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FULLSCREEN_MEDIA" object:[notification object]];
}

#pragma mark - Async Resource Observers

- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	//NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	
	_progressHUD.taskInProgress = NO;
	
	if (resource == _articleListResource) {
		NSError *error = nil;
		//NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		//NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
			_progressHUD.graceTime = 0.0;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSMutableArray *list = [NSMutableArray array];
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			int tot = 0;
			
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
				tot++;
			}
			
			_articles = list;
			_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
			[self configureWithSelectedIndex:0 fromItems:list];
			
			_paginationView = [[SNPaginationView alloc] initWithTotal:tot coords:CGPointMake(160.0, 468.0)];
			[self.view addSubview:_paginationView];
		}
	
	} else if (resource == _refreshListResource) {
		NSError *error = nil;
		//NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		//NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
			_progressHUD.graceTime = 0.0;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSMutableArray *list = [NSMutableArray array];
			[_progressHUD hide:YES];
			_progressHUD = nil;

			[_paginationView removeFromSuperview];
			_paginationView = nil;
			
			int tot = 0;
			
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
				tot++;
			}
			
			_articles = list;
			_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
			[self configureWithSelectedIndex:0 fromItems:list];

			_paginationView = [[SNPaginationView alloc] initWithTotal:tot coords:CGPointMake(160.0, 468.0)];
			[self.view addSubview:_paginationView];
		}
	}
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error
{
	if (_progressHUD != nil) {
		_progressHUD.graceTime = 0.0;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
		_progressHUD.labelText = NSLocalizedString(@"Error", @"Error");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}	
}


@end
