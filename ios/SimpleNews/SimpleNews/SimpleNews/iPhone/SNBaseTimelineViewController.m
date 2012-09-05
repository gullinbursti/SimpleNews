//
//  SNBaseTimelineViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 09.03.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GANTracker.h"
#import "ImageFilter.h"

#import "SNArticleItemView.h"
#import "SNNavLogoBtnView.h"

#import "SNHeaderView.h"
#import "SNNavLogoBtnView.h"
#import "SNAppDelegate.h"
#import "SNTweetVO.h"
#import "SNImageVO.h"

#import "SNAppDelegate.h"
#import "SNBaseTimelineViewController.h"
#import "MBLAsyncResource.h"
#import "MBLResourceLoader.h"

#import "SNProfileStatsView.h"

@interface SNBaseTimelineViewController () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *articleListResource;
@property(nonatomic, strong) MBLAsyncResource *updateListResource;

- (void)_retrieveTopicList;
- (void)_updateTopicList;

- (void)_retrieveProfileListWithType:(int)type;
@end


@implementation SNBaseTimelineViewController

@synthesize articleListResource = _articleListResource;
@synthesize updateListResource = _updateListResource;

@synthesize overlayView = _overlayView;


- (id)init {
	if ((self = [super init])) {
		self.view.frame = CGRectMake(226.0, 0.0, 320.0, 480.0);
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FULLSCREEN_MEDIA" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSourcePage:) name:@"SHOW_SOURCE_PAGE" object:nil];
		
		_articles = [NSMutableArray new];
		_articleViews = [NSMutableArray new];
		_hasImage = YES;
		_isProfile = NO;
	}
	
	return (self);
}

- (id)initAsFeed {
	if ((self = [self init])) {
		_timelineType = 4;
		_timelineTitle = @"Feed";
		
		NSLog(@"FEED:[%d]", _timelineType);
	}
	
	return (self);
}

- (id)initAsPopular {
	if ((self = [self init])) {
		_timelineType = 10;
		_timelineTitle = @"Popular";
		
		NSLog(@"POPULAR:[%d]", _timelineType);
	}
	
	return (self);
}

- (id)initAsActivity {
	if ((self = [self init])) {
		_timelineType = 6;
		_timelineTitle = @"Activity";
		_hasImage = NO;
		
		NSLog(@"ACTIVITY:[%d]", _timelineType);
	}
	
	return (self);
}

- (id)initAsProfile {
	if ((self = [self init])) {
		_timelineType = 15;
		_isProfile = YES;
		_timelineTitle = @"Profile";
		
		NSLog(@"PROFILE:[%d]", _timelineType);
	}
	
	return (self);
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



- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
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

- (void)_retrieveTopicList {
	if (_articleListResource == nil) {
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		//_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		//_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute expiration for now
	}
}

- (void)_updateTopicList {
	if (_updateListResource == nil) {
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		//_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 12] forKey:@"action"];
		//[formValues setObject:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		[formValues setObject:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[formValues setObject:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		
		NSLog(@"LAST DATE:[%@]", [dateFormat stringFromDate:_lastDate]);
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.updateListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate date]]; // 1 hour expiration for now
	}
}


- (void)_retrieveProfileListWithType:(int)type {
	if (_articleListResource == nil) {
		//NSLog(@"TYPE:[%d] (%@)", type, title);
		
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		//_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _timelineTitle];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", type] forKey:@"action"];
		[formValues setObject:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute for now
	}
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	bgImgView.image = [UIImage imageNamed:@"background_timeline.png"];
	[self.view addSubview:bgImgView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	NSLog(@"TITLE:[%d]", _timelineType);
	
	NSError *error;
	if (![[GANTracker sharedTracker] trackPageview:@"/activity/" withError:&error])
		NSLog(@"error in trackPageview");
	
	_vo = [SNTopicVO topicWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"topic_id", _timelineTitle, @"title", nil, @"hashtags", nil]];
	
	_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_activityIndicatorView.frame = CGRectMake(15.0, 60.0, 20.0, 20.0);
	[_activityIndicatorView startAnimating];
	[self.view addSubview:_activityIndicatorView];
	
	_loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 63.0, 245.0, 16.0)];
	_loaderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_loaderLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	_loaderLabel.textColor = [UIColor blackColor];
	_loaderLabel.backgroundColor = [UIColor clearColor];
	_loaderLabel.text = [NSString stringWithFormat:@"Assembling %@…", _timelineTitle];
	[self.view addSubview:_loaderLabel];
	
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = NO;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:_scrollView];
	
	if (_timelineType == 15) {
		UIView *profileHolderView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 8.0, 312.0, 40.0)];
		[_scrollView addSubview:profileHolderView];
		
		EGOImageView *profileImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 35.0, 35.0)];
		profileImgView.imageURL = [NSURL URLWithString:[SNAppDelegate twitterAvatar]];
		[profileHolderView addSubview:profileImgView];
		CGSize size = [[NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(52.0, 12.0, size.width, size.height)];
		label.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		label.textColor = [UIColor colorWithWhite:0.290 alpha:1.0];
		label.backgroundColor = [UIColor clearColor];
		label.shadowOffset = CGSizeMake(1.0, 1.0);
		label.text = [NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]];
		[profileHolderView addSubview:label];
		
		
		SNProfileStatsView *profileStatsView = [[SNProfileStatsView alloc]initWithFrame:CGRectMake(0.0, 46.0, 320.0, 84.0)];
		[_scrollView addSubview:profileStatsView];
	}
	
	//		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
	//		_refreshHeaderView.delegate = self;
	//		[_scrollView addSubview:_refreshHeaderView];
	//		[_refreshHeaderView refreshLastUpdatedDate];
	
	
	SNHeaderView *headerView = [[SNHeaderView alloc] initWithTitle:_timelineTitle];
	[self.view addSubview:headerView];
	
	_listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[_listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:_listBtnView];
	
	SNNavLogoBtnView *rndBtnView = [[SNNavLogoBtnView alloc] initWithFrame:CGRectMake(273.0, 0.0, 44.0, 44.0)];
	[[rndBtnView btn] addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	//[headerView addSubview:rndBtnView];
	
	_tabNavView = [[SNTabNavView alloc] initWithFrame:CGRectMake(0.0, 420.0, 320.0, 60.0)];
	[self.view addSubview:_tabNavView];
	
	[[_tabNavView feedButton] addTarget:self action:@selector(_goFeed) forControlEvents:UIControlEventTouchUpInside];
	[[_tabNavView popularButton] addTarget:self action:@selector(_goPopular) forControlEvents:UIControlEventTouchUpInside];
	[[_tabNavView activityButton] addTarget:self action:@selector(_goActivity) forControlEvents:UIControlEventTouchUpInside];
	[[_tabNavView profileButton] addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[[_tabNavView composeButton] addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	
	_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 88.0, 20.0, self.view.frame.size.height - 88.0)];
	//[_overlayView setBackgroundColor:[SNAppDelegate snDebugRedColor]];
	[self.view addSubview:_overlayView];
	
	[self _retrieveProfileListWithType:_timelineType];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Navigation
- (void)_goFeed {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FEED" object:nil];
}

- (void)_goPopular {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_POPULAR" object:nil];
}

- (void)_goActivity {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ACTIVITY" object:nil];
}

- (void)_goProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PROFILE" object:nil];
}

- (void)_goCompose {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_COMPOSER" object:nil];
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
				int offset = 6 + ((int)_isProfile * 126.0);
				for (NSDictionary *serverList in parsedLists) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
					//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
					if (vo != nil)
						[list addObject:vo];
					
					int height = 50;
					
					CGSize size;
					
					if (_hasImage) {
						height = 87;
						
						if (vo.totalLikes > 0) {
							height += 45;
						}
						
						int imgWidth = 290;
						//				if (vo.topicID == 1 || vo.topicID == 2)
						//					imgWidth = 296;			
						
						if ([vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
							//						imgWidth = 145;
							//						//height -= 2;
							height += 39;
							
							if (((SNImageVO *)[vo.images objectAtIndex:0]).ratio > 1.0)
								height--;
						}
						
						if (vo.type_id > 1 && vo.type_id - 4 < 0) {
							height += imgWidth * ((SNImageVO *)[vo.images objectAtIndex:0]).ratio;
							height += 9; //20
						}
						
						
						if (vo.topicID == 1 || vo.topicID == 2) {
							size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:13] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
							height += size.height + 11;
							
						} else if (vo.topicID == 10)
							height += 6;
						
						else
							height += 4;
						
						if (vo.type_id > 3) {
							height += 217;
							height += 7; //9
						}
					}
					
					SNArticleItemView *articleItemView = [[SNArticleItemView alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo showImage:_hasImage];
					[_articleViews addObject:articleItemView];
					
					offset += height;
					tot++;
					
					offset += 3;
				}
				
				[_progressHUD hide:YES];
				_progressHUD = nil;
				
				_articles = list;
				
				for (SNArticleItemView *itemView in _articleViews) {
					[_scrollView addSubview:itemView];
				}
				
				offset += 12.0;
				
				if ([_articles count] >= 10) {
					_loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
					_loadMoreButton.frame = CGRectMake(118.0, offset, 84.0, 38.0);
					[_loadMoreButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
					[_loadMoreButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
					[_loadMoreButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
					[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
					_loadMoreButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
					[_loadMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
					[_scrollView addSubview:_loadMoreButton];
					offset += 80.0;
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
				
				_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
				_refreshHeaderView.delegate = self;
				[_scrollView addSubview:_refreshHeaderView];
				[_refreshHeaderView refreshLastUpdatedDate];
				
			} else {
				UIAlertView *alert = [[UIAlertView alloc] 
											 initWithTitle:@"Refresh Error!" 
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
			int offset = _scrollView.contentSize.height - 75;
			for (NSDictionary *serverList in parsedLists) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
				
				int height;
				height = 87;
				CGSize size;
				
				if (vo.totalLikes > 0) {
					height += 45;
				}
				
				int imgWidth = 290;
				if ([vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
					//					imgWidth = 145;
					//height -= 2;
					height += 39;
					
					if (((SNImageVO *)[vo.images objectAtIndex:0]).ratio > 1.0)
						height--;
				}
				
				
				if (vo.type_id > 1 && vo.type_id - 4 < 0) {
					height += imgWidth * ((SNImageVO *)[vo.images objectAtIndex:0]).ratio;
					height += 9; //20
				}
				
				if (vo.topicID == 1 || vo.topicID == 2) {
					size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:13] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height + 11;
					
				} else if (vo.topicID == 10)
					height += 6;
				
				else
					height += 4;
				
				if (vo.type_id > 3) {
					height += 217;
					height += 7; //9
				}
				
				SNArticleItemView *articleItemView = [[SNArticleItemView alloc] initWithFrame:CGRectMake(10.0, offset, _scrollView.frame.size.width - 20.0, height) articleVO:vo showImage:_hasImage];
				[_articleViews addObject:articleItemView];
				
				[_scrollView addSubview:articleItemView];
				
				offset += height;
				tot++;
			}
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[_articles addObjectsFromArray:list];
			
			offset += 12.0;
			
			if ([_articles count] < 250) {
				_loadMoreButton.alpha = 1.0;
				_loadMoreButton.frame = CGRectMake(112.0, offset, 84.0, 38.0);
			}
			
			[_activityIndicatorView removeFromSuperview];
			[_loaderLabel removeFromSuperview];
			
			offset += 60.0;
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