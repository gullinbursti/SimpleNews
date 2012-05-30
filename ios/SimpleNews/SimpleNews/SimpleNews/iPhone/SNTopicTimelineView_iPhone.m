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

@implementation SNTopicTimelineView_iPhone

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(276.0, 0.0, 320.0, 480.0)])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fullscreenMedia:) name:@"FULLSCREEN_MEDIA" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSourcePage:) name:@"SHOW_SOURCE_PAGE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterTimeline:) name:@"TWITTER_TIMELINE" object:nil];
		
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		_timelineTweets = [NSMutableArray new];
        
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
		bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

-(id)initWithPopularArticles {
	if ((self = [self init])) {
		_vo = [SNTopicVO topicWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"topic_id", @"Popular", @"title", nil, @"hashtags", nil]];
		
		_articlesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 10] forKey:@"action"];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:@"/topics/0" withError:&error])
			NSLog(@"error in trackPageview");
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.frame.size.width, self.frame.size.height - 44.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = YES;
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
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;

	}
	
	return (self);
}

-(id)initWithTopicVO:(SNTopicVO *)vo {
	if ((self = [self init])) {
		_vo = vo;
		
		_articlesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/topics/%d", _vo.topic_id] withError:&error])
			NSLog(@"error in trackPageview");
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.frame.size.width, self.frame.size.height - 44.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = YES;
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
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
	}
	
	return (self);
}

- (void)reloadTableViewDataSource {
	_reloading = YES;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	if (_vo.topic_id == 0) {
		_updateRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", 11] forKey:@"action"];
		//[_updateRequest setPostValue:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", _lastID] forKey:@"articleID"];
		[_updateRequest setDelegate:self];
		[_updateRequest startAsynchronous];
	
	} else {
		NSLog(@"\n\n\n\n%d\n\n\n\n", _lastID);
		_updateRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
		[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		//[_updateRequest setPostValue:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", _lastID] forKey:@"articleID"];
		[_updateRequest setDelegate:self];
		[_updateRequest startAsynchronous];
	}
} 

- (void)doneLoadingTableViewData {
	_reloading = NO;
	
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FULLSCREEN_MEDIA" object:nil];
}

#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TIMELINE_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
}

#pragma mark - Notification handlers
-(void)_fullscreenMedia:(NSNotification *)notification {
	NSMutableDictionary *dict = [notification object];
	
	_articleVO = [dict objectForKey:@"VO"];
	[dict setValue:[NSNumber numberWithFloat:[[dict objectForKey:@"offset"] floatValue] - _scrollView.contentOffset.y] forKey:@"offset"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FULLSCREEN_MEDIA" object:dict];
}


-(void)_startVideo {
	[_videoPlayerView startPlayback];
}

-(void)_twitterTimeline:(NSNotification *)notification {
	_timelineTweets = (NSMutableArray *)[notification object];
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






#pragma mark - Image View delegates
-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	imageView.image = [SNAppDelegate imageWithFilters:imageView.image filter:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"sharpen", @"type", [NSNumber numberWithFloat:1.0], @"amount", nil], nil]];
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNTopicTimelineView_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:_articlesRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSArray *parsedArticles = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *articleList = [NSMutableArray array];
				_cardViews = [NSMutableArray new];
				
				int tot = 0;
				int offset = 10;
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					
					//NSLog(@"ARTICLE \"%@\"", vo.title);
					
					if (vo != nil)
						[articleList addObject:vo];
					
					int height;
					height = 150;
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
											
					SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo];
					[_cardViews addObject:articleItemView];
					
					offset += 20;
					offset += height;
					tot++;
				}
				
				_articles = [articleList copy];
				
				for (SNArticleItemView_iPhone *itemView in _cardViews) {
					[_scrollView addSubview:itemView];
				}
				
				_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, offset);
			}
		}
		
		if ([_articles count] > 0) {
			_lastID = ((SNArticleVO *)[_articles objectAtIndex:0]).article_id;
			_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
		}
		
		[_progressHUD hide:YES];
		
	} else if ([request isEqual:_updateRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSArray *parsedArticles = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
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
					
					SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo];
					[_cardViews addObject:articleItemView];
					
					offset += 20;
					offset += height;
					tot++;
				}
				
				for (SNArticleItemView_iPhone *articleItemView in _cardViews) {
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
					
					SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, offset, _scrollView.frame.size.width, height) articleVO:vo];
					[_cardViews addObject:articleItemView];
					
					offset += 20;
					offset += height;
					tot++;
				}
				
				for (SNArticleItemView_iPhone *itemView in _cardViews) {
					[_scrollView insertSubview:itemView atIndex:0];
				}
				
				
				NSMutableArray *updatedArticles = [NSMutableArray arrayWithArray:articleList];
				[updatedArticles addObjectsFromArray:_articles];
				
				if ([updatedArticles count] > 0) {
					_lastID = ((SNArticleVO *)[updatedArticles lastObject]).article_id;
					_articles = [updatedArticles copy];
				}
				
				_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + offset);
			}
		}
		
		_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
		[self doneLoadingTableViewData];
	}
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SUBSCRIBED_LIST" object:nil];
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
