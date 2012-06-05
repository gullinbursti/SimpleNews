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
#import "SNNavListBtnView.h"
#import "SNNavLogoBtnView.h"
#import "SNAppDelegate.h"
#import "SNTweetVO.h"

#import "SNTopicTimelineView_iPhone.h"
#import "MBLResourceLoader.h"

@interface SNTopicTimelineView_iPhone () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *articleListResource;
@property(nonatomic, strong) MBLAsyncResource *updateListResource;
- (void)_refreshArticleList;
- (void)_refreshPopularList;
- (void)_updateArticleList;
- (void)_updatePopularList;
@end

@implementation SNTopicTimelineView_iPhone

@synthesize articleListResource = _articleListResource;
@synthesize updateListResource = _updateListResource;

@synthesize overlayView = _overlayView;

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(276.0, 0.0, 320.0, 480.0)])) {
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
		
		[self _refreshPopularList];
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
		
		SNNavListBtnView *listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
		[[listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:listBtnView];
		
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 40.0, self.frame.size.height - 44.0)];
		[self addSubview:_overlayView];
		
		[self _refreshArticleList];
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
//		[self _updateArticleList];
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


- (void)_refreshPopularList {
	if (_articleListResource == nil) {
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		//_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.labelText = [NSString stringWithFormat:@"Loading %@…", _vo.title];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 10] forKey:@"action"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute for now
	}
}

- (void)_refreshArticleList {
	if (_articleListResource == nil) {
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.labelText = [NSString stringWithFormat:@"Loading %@…", _vo.title];
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

- (void)_updatePopularList {
	if (_updateListResource == nil) {
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 11] forKey:@"action"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _lastID] forKey:@"articleID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.updateListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate date]]; // 1 hour expiration for now
	}
}

- (void)_updateArticleList {
	if (_updateListResource == nil) {
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _lastID] forKey:@"articleID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"];
		self.updateListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate date]]; // 1 hour expiration for now
	}
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

- (void)fullscreenMediaEnabled:(BOOL)isEnabled {
	if (isEnabled)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fullscreenMedia:) name:@"FULLSCREEN_MEDIA" object:nil];
	
	else
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FULLSCREEN_MEDIA" object:nil];	
}


#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TIMELINE_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
}

#pragma mark - Notification handlers
-(void)_fullscreenMedia:(NSNotification *)notification {
	NSLog(@"_fullscreenMedia");
	NSMutableDictionary *dict = [notification object];
	
	_articleVO = [dict objectForKey:@"VO"];
	[dict setValue:[NSNumber numberWithFloat:[[dict objectForKey:@"offset"] floatValue] - _scrollView.contentOffset.y] forKey:@"offset"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FULLSCREEN_MEDIA" object:dict];
}

-(void)_showSourcePage:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	//NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
	//							 vo.article_url, @"url", 
	//							 vo.title, @"title", nil];
	
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
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
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
			
			int tot = 0;
			int offset = 6;
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
				
				int height;
				height = 94;
				CGSize size;
				
				int imgWidth = 305;
				if (vo.topicID == 1 || vo.topicID == 2)
					imgWidth = 296;			
				
				if (vo.type_id > 1 && vo.type_id - 4 < 0) {
					height += imgWidth * vo.imgRatio;
					height += 26; //20
				}
				
				if (!(vo.topicID == 8)) {
					size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height + 9;
				}
				
				if (vo.type_id > 3) {
					height += 229;
					height += 26; //9
				}
				
				if ([vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
					height += 37;
				}
				
				SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo];
				[_articleViews addObject:articleItemView];
				
				offset += height;
				tot++;
			}
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			_articles = list;
			
			for (SNArticleItemView_iPhone *itemView in _articleViews) {
				[_scrollView addSubview:itemView];
			}
			
			[_activityIndicatorView removeFromSuperview];
			[_loaderLabel removeFromSuperview];
			
			_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, offset);
		}
	
	} else if (resource == _updateListResource) {
		NSError *error = nil;
		NSArray *parsedArticles = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
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
			int tot = 0;
			int offset = 0;
			for (NSDictionary *serverArticle in parsedArticles) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
				
				int height;
				height = 210;
				CGSize size;
				
				if (vo.type_id > 1) {
					height += 270.0 * vo.imgRatio;
					height += 20;
				}
				
				size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
				height += size.height;
				
				if (vo.type_id > 4) {
					height += 202;
					offset += 20;
				}
				
				offset += 20;
				offset += height;
				tot++;
			}
			
			for (SNArticleItemView_iPhone *articleItemView in _articleViews) {
				[UIView animateWithDuration:0.5 animations:^(void) {
					articleItemView.frame = CGRectMake(0.0, articleItemView.frame.origin.y + offset, articleItemView.frame.size.width, articleItemView.frame.size.height);
				}];
			}
			
			offset = 10;
			
			NSMutableArray *articleList = [NSMutableArray array];
			for (NSDictionary *serverArticle in parsedArticles) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
				
				if (vo != nil)
					[articleList addObject:vo];
				
				int height;
				height = 210;
				CGSize size;
				
				if (vo.type_id > 1) {
					height += 270.0 * vo.imgRatio;
					height += 20;
				}
				
				size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
				height += size.height;
				
				if (vo.type_id > 4) {
					height += 202;
					offset += 20;
				}
				
				SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width, height) articleVO:vo];
				[_articleViews addObject:articleItemView];
				
				offset += 20;
				offset += height;
				tot++;
			}
			
			for (SNArticleItemView_iPhone *itemView in _articleViews) {
				[_scrollView insertSubview:itemView atIndex:0];
			}
			
			
			NSMutableArray *updatedArticles = [NSMutableArray arrayWithArray:articleList];
			[updatedArticles addObjectsFromArray:_articles];
			
			if ([updatedArticles count] > 0) {
				_lastID = ((SNArticleVO *)[updatedArticles lastObject]).article_id;
				_articles = [updatedArticles copy];
			}
			
			_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + offset);
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
			[self doneLoadingTableViewData];
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
