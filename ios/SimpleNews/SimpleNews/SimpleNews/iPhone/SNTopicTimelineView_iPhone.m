//
//  SNTopicTimelineView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.18.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GANTracker.h"
#import "ImageFilter.h"

#import "SNArticleItemView_iPhone.h"
#import "SNHeaderView_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavTitleView.h"
#import "SNNavLogoBtnView.h"
#import "SNAppDelegate.h"
#import "SNTweetVO.h"
#import "SNImageVO.h"

#import "SNTopicTimelineView_iPhone.h"
#import "MBLResourceLoader.h"

@interface SNTopicTimelineView_iPhone () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *articleListResource;
@property(nonatomic, strong) MBLAsyncResource *updateListResource;

- (void)_retrieveTopicList;
- (void)_updateTopicList;

- (void)_retrievePopularList;
- (void)_updatePopularList;

- (void)_retrieveProfileListWithType:(int)type;
@end

@implementation SNTopicTimelineView_iPhone

@synthesize articleListResource = _articleListResource;
@synthesize updateListResource = _updateListResource;

@synthesize overlayView = _overlayView;

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(226.0, 0.0, 320.0, 480.0)])) {
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FULLSCREEN_MEDIA" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSourcePage:) name:@"SHOW_SOURCE_PAGE" object:nil];
		
		_articles = [NSMutableArray new];
		_articleViews = [NSMutableArray new];
        
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
		bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

-(id)initWithPopularArticles {
	if ((self = [self init])) {
		_vo = [SNTopicVO topicWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"topic_id", @"Popular", @"title", nil, @"hashtags", nil]];
				
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:@"/topics/0" withError:&error])
			NSLog(@"error in trackPageview");
		
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicatorView.frame = CGRectMake(15.0, 60.0, 20.0, 20.0);
		[_activityIndicatorView startAnimating];
		[self addSubview:_activityIndicatorView];
		
		_loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 63.0, 145.0, 16.0)];
		_loaderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_loaderLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		_loaderLabel.textColor = [UIColor blackColor];
		_loaderLabel.backgroundColor = [UIColor clearColor];
		_loaderLabel.text = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		[self addSubview:_loaderLabel];

		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.frame.size.width, self.frame.size.height - 44.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = NO;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = NO;
		_scrollView.delegate = self;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
		[self addSubview:_scrollView];
		
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		_refreshHeaderView.delegate = self;
		[_scrollView addSubview:_refreshHeaderView];
		[_refreshHeaderView refreshLastUpdatedDate];
		
		SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.title];
		[self addSubview:headerView];
		
		SNNavListBtnView *listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
		[[listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:listBtnView];
		
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 40.0, self.frame.size.height - 44)];
		[self addSubview:_overlayView];
		
		[self _retrievePopularList];
	}
	
	return (self);
}

-(id)initWithTopicVO:(SNTopicVO *)vo {
	if ((self = [self init])) {
		_vo = vo;
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/topics/%d", _vo.topic_id] withError:&error])
			NSLog(@"error in trackPageview");
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicatorView.frame = CGRectMake(15.0, 60.0, 20.0, 20.0);
		[_activityIndicatorView startAnimating];
		[self addSubview:_activityIndicatorView];
		
		_loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 63.0, 250.0, 16.0)];
		_loaderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_loaderLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		_loaderLabel.textColor = [UIColor blackColor];
		_loaderLabel.backgroundColor = [UIColor clearColor];
		_loaderLabel.text = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		[self addSubview:_loaderLabel];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.frame.size.width, self.frame.size.height - 44.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = NO;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = NO;
		_scrollView.delegate = self;
		_scrollView.showsVerticalScrollIndicator = YES;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
		[self addSubview:_scrollView];
		
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		_refreshHeaderView.delegate = self;
		[_scrollView addSubview:_refreshHeaderView];
		[_refreshHeaderView refreshLastUpdatedDate];
		
		SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.title];
		[self addSubview:headerView];
		
		_listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
		[[_listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:_listBtnView];
		
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 40.0, self.frame.size.height - 44.0)];
		[self addSubview:_overlayView];
		
		[self _retrieveTopicList];
	}
	
	return (self);
}

- (id) initWithProfileType:(int)type {
	if ((self = [self init])) {
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:@"/topics/0" withError:&error])
			NSLog(@"error in trackPageview");
		
		NSString *title;
		
		switch (type) {
			case 6:
				title = @"My Likes";
				break;
				
			case 2:
				title = @"My Comments";
				break;
				
			case 5:
				title = @"Shares";
				break;
		}
		
		_vo = [SNTopicVO topicWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"topic_id", title, @"title", nil, @"hashtags", nil]];
		
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicatorView.frame = CGRectMake(15.0, 60.0, 20.0, 20.0);
		[_activityIndicatorView startAnimating];
		[self addSubview:_activityIndicatorView];
		
		_loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 63.0, 245.0, 16.0)];
		_loaderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_loaderLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		_loaderLabel.textColor = [UIColor blackColor];
		_loaderLabel.backgroundColor = [UIColor clearColor];
		_loaderLabel.text = [NSString stringWithFormat:@"Assembling %@…", title];
		[self addSubview:_loaderLabel];
		
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.frame.size.width, self.frame.size.height - 44.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = NO;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = NO;
		_scrollView.delegate = self;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
		[self addSubview:_scrollView];
		
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		_refreshHeaderView.delegate = self;
		[_scrollView addSubview:_refreshHeaderView];
		[_refreshHeaderView refreshLastUpdatedDate];
		
		
		SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.title];
		[self addSubview:headerView];
		
		SNNavListBtnView *listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
		[[listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:listBtnView];
		
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 40.0, self.frame.size.height - 44)];
		[self addSubview:_overlayView];
		
		[self _retrieveProfileListWithType:type];
	}
	
	return (self);
}

- (void)reloadTableViewDataSource {
	_reloading = YES;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
//	if (_vo.topic_id == 0) {
//		[self _updatePopularList];
//	
//	} else {
//		NSLog(@"\n\n\n\n%d\n\n\n\n", _lastID);
//		[self _updateTopicList];
//	}
	
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.33];
} 

- (void)doneLoadingTableViewData {
	_reloading = NO;
	
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FULLSCREEN_MEDIA" object:nil];
	
	if (_articleListResource != nil) {
		[_articleListResource unsubscribe:self];
		_articleListResource = nil;
	}
	
	if (_updateListResource != nil) {
		[_updateListResource unsubscribe:self];
		_updateListResource = nil;
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

- (void)setUpdateListResource:(MBLAsyncResource *)updateListResource {
	if (_updateListResource != nil) {
		[_updateListResource unsubscribe:self];
		_updateListResource = nil;
	}
	
	_updateListResource = updateListResource;
	
	if (_updateListResource != nil)
		[_updateListResource subscribe:self];
}


- (void)_retrievePopularList {
	if (_articleListResource == nil) {
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		//_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 10] forKey:@"action"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute for now
	}
}

- (void)_updatePopularList {
	_updateListResource = nil;
	
	if (_updateListResource == nil) {
		_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 12] forKey:@"action"];
		[formValues setObject:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.updateListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate date]]; // 1 hour expiration for now
	}
}

- (void)_retrieveTopicList {
	if (_articleListResource == nil) {
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		//_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute expiration for now
	}
}

- (void)_updateTopicList {
	if (_updateListResource == nil) {
		_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 13] forKey:@"action"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		[formValues setObject:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.updateListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate date]]; // 1 hour expiration for now
	}
}


- (void)_retrieveProfileListWithType:(int)type {
	
	if (_articleListResource == nil) {
		NSString *title;
		
		switch (type) {
			case 6:
				title = @"My Likes";
				break;
				
			case 2:
				title = @"My Comments";
				break;
				
			case 5:
				title = @"Shares";
				break;
		}
		
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		//_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", title];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", type] forKey:@"action"];
		[formValues setObject:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute for now
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
		
	
	_scrollView.userInteractionEnabled = isEnabled;
}


#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TIMELINE_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
}

- (void)_goLoadMore {
	
	if (_vo.topic_id == 0)
		[self _updatePopularList];
	
	else
		[self _updateTopicList];
	
	_loadMoreButton.alpha = 0.5;
}

- (void)_goShow {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TIMELINE" object:nil];
}

#pragma mark - Notification handlers
-(void)_fullscreenMedia:(NSNotification *)notification {
	NSMutableDictionary *dict = [notification object];
	
	NSLog(@"SCROLL-Y:[%f]", [[NSNumber numberWithFloat:[[dict objectForKey:@"offset"] floatValue]] floatValue]);
	
	_articleVO = [dict objectForKey:@"article_vo"];
	[dict setValue:[NSNumber numberWithFloat:[[dict objectForKey:@"offset"] floatValue] - _scrollView.contentOffset.y] forKey:@"offset"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FULLSCREEN_MEDIA" object:dict];
}

-(void)_showSourcePage:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_PAGE" object:vo];
}


#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date]; // should return date data source was last change	
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
	for (SNArticleItemView_iPhone *itemView in _articleViews) {
		if (scrollView.contentOffset.y + 340.0 > itemView.frame.origin.y && itemView.isFirstAppearance) {
			[itemView setIsFirstAppearance:NO];
			
			[UIView animateWithDuration:0.25 animations:^(void) {
				itemView.alpha = 1.0;
			}];
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.25];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
			CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
			itemView.transform = transform;
			[UIView commitAnimations];
		}
	}
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TOPIC" object:[NSNumber numberWithInt:_vo.topic_id]];
	}
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
			if ([parsedLists count] > 0) {
			
				NSMutableArray *list = [NSMutableArray array];
				
				int tot = 0;
				int offset = 6;
				for (NSDictionary *serverList in parsedLists) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
					//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
					if (vo != nil)
						[list addObject:vo];
					
					int height;
					height = 88;
					CGSize size;
					
					if (vo.totalLikes > 0) {
						height += 51;
					}
					
					int imgWidth = 290;
	//				if (vo.topicID == 1 || vo.topicID == 2)
	//					imgWidth = 296;			
					
					if ([vo.article_url rangeOfString:@"itunes.apple.com"].length > 0)
						imgWidth = 150;
						
					if (vo.type_id > 1 && vo.type_id - 4 < 0) {
						height += imgWidth * ((SNImageVO *)[vo.images objectAtIndex:0]).ratio;
						height += 9; //20
					}
					
					
					if (!(vo.topicID == 8)) {
						size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:13] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
						height += size.height + 9;
					}
					
					if (vo.type_id > 3) {
						height += 217;
						height += 26; //9
					}
					
					SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo];
					[_articleViews addObject:articleItemView];
					
					offset += height;
					tot++;
					
					offset += 3;
				}
				
				[_progressHUD hide:YES];
				_progressHUD = nil;
				
				_articles = list;
				
				for (SNArticleItemView_iPhone *itemView in _articleViews) {
					[_scrollView addSubview:itemView];
					
					if (itemView.frame.origin.y > 480.0) {
						itemView.alpha = 0.0;
						[UIView beginAnimations:nil context:NULL];
						[UIView setAnimationDuration:0.1];
						[UIView setAnimationDelegate:self];
						[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
						CGAffineTransform transform = CGAffineTransformMakeScale(1.1, 1.1);
						itemView.transform = transform;
						[UIView commitAnimations];
					}
				}
				
				offset += 16.0;
				
				if ([_articles count] == 30 && [_articles count] < 250) {
					_loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
					_loadMoreButton.frame = CGRectMake(112.0, offset, 96.0, 34.0);
					[_loadMoreButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateNormal];
					[_loadMoreButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];		
					[_loadMoreButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
					[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
					_loadMoreButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:10.0];
					[_loadMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
					[_scrollView addSubview:_loadMoreButton];
					offset += 50.0;
				}
				
				_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, offset);
				
				if ([_articles count] > 0) {
					_lastID = ((SNArticleVO *)[_articles lastObject]).article_id;
					_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
					
					//NSLog(@"FIST DATE:[%@]", ((SNArticleVO *)[_articles objectAtIndex:0]).added);
					//NSLog(@"LAST DATE:[%@]", _lastDate);
				}
				
				[_activityIndicatorView removeFromSuperview];
				[_loaderLabel removeFromSuperview];
				
			} else {
				UIAlertView *alert = [[UIAlertView alloc] 
											 initWithTitle:@"Nothing Here" 
											 message:@"Cannot Refresh Content"
											 delegate:nil
											 cancelButtonTitle:@"OK" 
											 otherButtonTitles:nil];
				
				[alert show];
				
				[_activityIndicatorView removeFromSuperview];
				[_loaderLabel removeFromSuperview];
			}
		}
	
	} else if (resource == _updateListResource) {
		NSError *error = nil;
		
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
			
			int tot = 0;
			int offset = _scrollView.contentSize.height - 50;
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
				
				int height;
				height = 88;
				CGSize size;
				
				if (vo.totalLikes > 0) {
					height += 51;
				}
				
				int imgWidth = 290;
				
				
				if (vo.type_id > 1 && vo.type_id - 4 < 0) {
					height += imgWidth * ((SNImageVO *)[vo.images objectAtIndex:0]).ratio;
					height += 26; //20
				}
				
				if (!(vo.topicID == 8)) {
					size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:15] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height + 9;
				}
				
				if (vo.type_id > 3) {
					height += 217;
					height += 26; //9
				}
				
				SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo];
				[_articleViews addObject:articleItemView];
				
				[_scrollView addSubview:articleItemView];
				
				if (articleItemView.frame.origin.y > 480.0) {
					articleItemView.alpha = 0.0;
					[UIView beginAnimations:nil context:NULL];
					[UIView setAnimationDuration:0.1];
					[UIView setAnimationDelegate:self];
					[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
					CGAffineTransform transform = CGAffineTransformMakeScale(1.1, 1.1);
					articleItemView.transform = transform;
					[UIView commitAnimations];
				}
				
				if (tot == 0) {
					[articleItemView setIsFirstAppearance:NO];
					
					[UIView animateWithDuration:0.25 animations:^(void) {
						articleItemView.alpha = 1.0;
					}];
					
					[UIView beginAnimations:nil context:NULL];
					[UIView setAnimationDuration:0.25];
					[UIView setAnimationDelegate:self];
					[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
					CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
					articleItemView.transform = transform;
					[UIView commitAnimations];
				}
				
				
				offset += height;
				tot++;
				
				offset += 3;
			}
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[_articles addObjectsFromArray:list];
			
			offset += 16.0;
			
			if ([_articles count] < 250) {
				_loadMoreButton.alpha = 1.0;
				_loadMoreButton.frame = CGRectMake(112.0, offset, 96.0, 44.0);
			}
			
			[_activityIndicatorView removeFromSuperview];
			[_loaderLabel removeFromSuperview];
			
			offset += 50.0;
			_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, offset);
			
			if ([_articles count] > 0) {
				_lastID = ((SNArticleVO *)[_articles lastObject]).article_id;
				_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
				
				//NSLog(@"FIST DATE:[%@]", ((SNArticleVO *)[_articles objectAtIndex:0]).added);
				//NSLog(@"LAST DATE:[%@]", _lastDate);
			}
			
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
