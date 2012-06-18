//
//  SNDiscoveryListView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNDiscoveryListView_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNNavListBtnView.h"
#import "SNNavLogoBtnView.h"
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


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
		bgImgView.image = [UIImage imageNamed:@"timelineDiscoverBackground.png"];
		[self addSubview:bgImgView];
		
		_cardViews = [NSMutableArray new];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.frame.size.width, self.frame.size.height - 44.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = NO;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width, _scrollView.frame.size.height);
		[self addSubview:_scrollView];
		
		SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Discovery"];
		[self addSubview:headerView];
		
		SNNavListBtnView *listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
		[[listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:listBtnView];
		
		SNNavLogoBtnView *logoBtnView = [[SNNavLogoBtnView alloc] initWithFrame:CGRectMake(276.0, 0.0, 44.0, 44.0)];
		[[logoBtnView btn] addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:logoBtnView];
		
		[self _retrieveArticleList];
	}
	
	return (self);
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
		_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.taskInProgress = YES;
		_progressHUD.graceTime = 3.0;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 14] forKey:@"action"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute expiration for now
	}
}

- (void)_refreshArticleList {
	_refreshListResource = nil;
	
	if (_refreshListResource == nil) {
		_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.taskInProgress = YES;
		_progressHUD.graceTime = 3.0;
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 15] forKey:@"action"];
		[formValues setObject:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.refreshListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute expiration for now
	}
}


#pragma mark - Navigation
- (void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DISCOVERY_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
}

- (void)_goRefresh {
	[self _refreshArticleList];
}

#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_paginationView changeToPage:_scrollView.contentOffset.x / 320.0];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
}



#pragma mark - Async Resource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	
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
				
				
				SNDiscoveryItemView_iPhone *discoveryItemView = [[SNDiscoveryItemView_iPhone alloc] initWithFrame:CGRectMake(tot * 320.0, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height) articleVO:vo];
				[_cardViews addObject:discoveryItemView];
				
				tot++;
			}
			
			_articles = list;
			
			for (SNDiscoveryItemView_iPhone *itemView in _cardViews)
				[_scrollView addSubview:itemView];
			
			_scrollView.contentSize = CGSizeMake(tot * self.frame.size.width, _scrollView.frame.size.height);
			_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
			
			_paginationView = [[SNPaginationView alloc] initWithTotal:tot coords:CGPointMake(160.0, 465.0)];
			[self addSubview:_paginationView];
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
			
			for (SNDiscoveryItemView_iPhone *itemView in _cardViews)
				[itemView removeFromSuperview];
			
			_cardViews = [NSMutableArray new];
			
			[_paginationView removeFromSuperview];
			_paginationView = nil;
			
			int tot = 0;
			
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
				
				
				SNDiscoveryItemView_iPhone *discoveryItemView = [[SNDiscoveryItemView_iPhone alloc] initWithFrame:CGRectMake(tot * 320.0, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height) articleVO:vo];
				[_cardViews addObject:discoveryItemView];
				
				tot++;
			}
			
			_articles = list;
			
			for (SNDiscoveryItemView_iPhone *itemView in _cardViews)
				[_scrollView addSubview:itemView];
			
			_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
			_scrollView.contentSize = CGSizeMake(tot * self.frame.size.width, _scrollView.frame.size.height);
			
			_paginationView = [[SNPaginationView alloc] initWithTotal:tot coords:CGPointMake(160.0, 465.0)];
			[self addSubview:_paginationView];
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
