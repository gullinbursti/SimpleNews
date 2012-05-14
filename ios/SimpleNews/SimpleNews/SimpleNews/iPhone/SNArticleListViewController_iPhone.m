//
//  SNArticleListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "GANTracker.h"
#import "ImageFilter.h"

#import "SNArticleListViewController_iPhone.h"
#import "SNArticleItemView_iPhone.h"
#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavTitleView.h"
#import "SNNavListBtnView.h"
#import "SNNavLogoBtnView.h"
#import "SNAppDelegate.h"
#import "SNTweetVO.h"

#import "SNArticleSourcesViewController_iPhone.h"
#import "SNWebPageViewController_iPhone.h"

@interface SNArticleListViewController_iPhone()
-(void)_goBack;
@end

@implementation SNArticleListViewController_iPhone

#define kImageScale 0.9

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showComments:) name:@"SHOW_COMMENTS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFullscreenMedia:) name:@"SHOW_FULLSCREEN_MEDIA" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideFullscreenMedia:) name:@"HIDE_FULLSCREEN_MEDIA" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_readLater:) name:@"READ_LATER" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showDetails:) name:@"SHOW_DETAILS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSourcePage:) name:@"SHOW_SOURCE_PAGE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterTimeline:) name:@"TWITTER_TIMELINE" object:nil];
		
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		_timelineTweets = [NSMutableArray new];
	}
	
	return (self);
}


-(id)initWithListVO:(SNListVO *)vo {
	if ((self = [self init])) {
		_vo = vo;
		
		_articlesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/lists/%d", _vo.list_id] withError:&error])
			NSLog(@"error in trackPageview");
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_TIMER" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOP_TIMER" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_TWITTER_PROFILE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_TWEET_PAGE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_SOURCE_PAGE" object:nil];
}


#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:_scrollView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	_refreshHeaderView.delegate = self;
	[_scrollView addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.list_name];
	[self.view addSubview:headerView];
	
	SNNavListBtnView *listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:listBtnView];
	
	SNNavLogoBtnView *logoBtnView = [[SNNavLogoBtnView alloc] initWithFrame:CGRectMake(276.0, 0.0, 44.0, 44.0)];
	[[logoBtnView btn] addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:logoBtnView];
	
	if (!_vo.isSubscribed) {
		_subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_subscribeBtn.frame = CGRectMake(210.0, 50.0, 105.0, 44.0);
		[_subscribeBtn setBackgroundImage:[UIImage imageNamed:@"followTopicButton_nonActive.png"] forState:UIControlStateNormal];
		[_subscribeBtn setBackgroundImage:[UIImage imageNamed:@"followTopicButton_Active.png"] forState:UIControlStateHighlighted];
		[_subscribeBtn setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_subscribeBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11.0];
		_subscribeBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -10.0);
		[_subscribeBtn setTitle:@"Follow Topic" forState:UIControlStateNormal];
		[_subscribeBtn addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:_subscribeBtn];
	}
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.view.frame];
	[_blackMatteView setBackgroundColor:[UIColor blackColor]];
	_blackMatteView.alpha = 0.0;
	[self.view addSubview:_blackMatteView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
}

-(void)viewDidUnload {
	_progressHUD = nil;
	_fullscreenImgView = nil;
	_videoPlayerView = nil;
	_blackMatteView = nil;
	
	[super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	
	if (CGRectContainsPoint(_videoPlayerView.frame, touchPoint))
		[_videoPlayerView toggleControls];//NSLog(@"TOUCHED:(%f, %f)", touchPoint.x, touchPoint.y);
}


- (void)reloadTableViewDataSource {
	_reloading = YES;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	_updateRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
	[_updateRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[_updateRequest setPostValue:[dateFormat stringFromDate:((SNArticleVO *)[_articles objectAtIndex:0]).added] forKey:@"datetime"];
	[_updateRequest setDelegate:self];
	[_updateRequest startAsynchronous];
} 

- (void)doneLoadingTableViewData {
	_reloading = NO;
	
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}


#pragma mark - Navigation
-(void)_goBack {	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ARTICLES_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goFlip {
	[self.navigationController pushViewController:[[SNArticleSourcesViewController_iPhone alloc] initWithListVO:_vo] animated:YES];
}

-(void)_goSubscribe {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		
	} else {
		ASIFormDataRequest *subscribeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[subscribeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[subscribeRequest setDelegate:self];
		[subscribeRequest startAsynchronous];
		
		[_subscribeBtn removeFromSuperview];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"Following Topic" action:_vo.list_name label:nil value:-1 withError:&error])
			NSLog(@"error in trackEvent");
	}
} 

#pragma mark - Notification handlers
-(void)_showFullscreenMedia:(NSNotification *)notification {
	NSLog(@"SHOW MEDIA");
	NSDictionary *dict = [notification object];
	
	SNArticleVO *vo = [dict objectForKey:@"VO"];
	float offset = [[dict objectForKey:@"offset"] floatValue];
	CGRect frame = [[dict objectForKey:@"frame"] CGRectValue];
	NSString *type = [dict objectForKey:@"type"];
	
	frame.origin.y = 44.0 + frame.origin.y + offset - _scrollView.contentOffset.y;
	_fullscreenFrame = frame;
	
	if ([type isEqualToString:@"photo"]) {
		_fullscreenImgView = [[EGOImageView alloc] initWithFrame:frame];
		_fullscreenImgView.delegate = self;
		_fullscreenImgView.imageURL = [NSURL URLWithString:vo.bgImage_url];
		_fullscreenImgView.userInteractionEnabled = YES;
		[self.view addSubview:_fullscreenImgView];
		
	} else if ([type isEqualToString:@"video"]) {
		_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:frame articleVO:vo];
		[self.view addSubview:_videoPlayerView];
	}
	
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_blackMatteView.alpha = 0.95;
		
		if ([type isEqualToString:@"photo"])
			_fullscreenImgView.frame = CGRectMake(0.0, (self.view.frame.size.height - (self.view.frame.size.width * vo.imgRatio)) * 0.5, self.view.frame.size.width, self.view.frame.size.width * vo.imgRatio);
		
		else
			[_videoPlayerView reframe:CGRectMake(0.0, (self.view.frame.size.height - 240.0) * 0.5, self.view.frame.size.width, 240.0)];
		
		
	} completion:^(BOOL finished) {
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_hideFullscreenImage:)];
		tapRecognizer.numberOfTapsRequired = 1;
		
		if ([type isEqualToString:@"photo"])
			[_fullscreenImgView addGestureRecognizer:tapRecognizer];
		
		else
			[_blackMatteView addGestureRecognizer:tapRecognizer];
	}];
}

-(void)_hideFullscreenImage:(UIGestureRecognizer *)gestureRecognizer {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
		
		_fullscreenImgView.frame = _fullscreenFrame;
		[_videoPlayerView reframe:_fullscreenFrame];
		[_videoPlayerView stopPlayback];
		
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
		[_fullscreenImgView removeFromSuperview];
		[_videoPlayerView removeFromSuperview];
		
		_fullscreenImgView = nil;
		_videoPlayerView = nil;
	}];
}

-(void)_showComments:(NSNotification *)notification {
	[self.navigationController pushViewController:[[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object] listID:_vo.list_id] animated:YES];
}


-(void)_readLater:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CANCEL_SHARE" object:nil];	
}
-(void)_twitterShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
	
	//[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
	[twitter addURL:[NSURL URLWithString:[NSString stringWithString:[NSString stringWithFormat:@"http://assemb.ly/tweets?id=%@", vo.tweet_id]]]];
	[twitter setInitialText:[NSString stringWithFormat:@"via Assembly - %@", vo.title]];
	
	[self presentModalViewController:twitter animated:YES];
	
	twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
		
		ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", vo.article_id] forKey:@"articleID"];
		[readRequest setDelegate:self];
		[readRequest startAsynchronous];
		//NSString *msg; 
		
		//if (result == TWTweetComposeViewControllerResultDone)
		//	msg = @"Tweet compostion completed.";
		
		//else if (result == TWTweetComposeViewControllerResultCancelled)
		//	msg = @"Tweet composition canceled.";
		
		
		//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tweet Status" message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		//[alertView show];
		
		[self dismissModalViewControllerAnimated:YES];
	};
}

-(void)_twitterTimeline:(NSNotification *)notification {
	_timelineTweets = (NSMutableArray *)[notification object];
}

-(void)_showDetails:(NSNotification *)notification {
	SNArticleDetailsViewController_iPhone *articleDetailsViewController = [[SNArticleDetailsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object]];
	[self.navigationController pushViewController:articleDetailsViewController animated:YES];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showSourcePage:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[[notification object] objectForKey:@"url"]] title:[[notification object] objectForKey:@"title"]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
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
	imageView.image = [SNAppDelegate imageWithFilters:imageView.image filter:[NSArray arrayWithObjects:
																									  [NSDictionary dictionaryWithObjectsAndKeys:
																										@"sepia", @"type", nil, nil], 
																									  nil]];
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleListViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
				int offset = 0;
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					
					//NSLog(@"ARTICLE \"%@\"", vo.title);
					
					if (vo != nil)
						[articleList addObject:vo];
					
					int height;
					if (vo.source_id > 0) {
						height = 220;
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
						
					} else {
						height = 59;
					}
					
					
					SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, offset, _scrollView.frame.size.width, height) articleVO:vo];
					[_cardViews addObject:articleItemView];
					
					offset += height;
					tot++;
					
					if (tot == 5 && !_vo.isSubscribed)
						break;
				}
				
				_articles = [articleList copy];
				
				for (SNArticleItemView_iPhone *itemView in _cardViews) {
					[_scrollView addSubview:itemView];
				}
				
				_lastDate = ((SNArticleVO *)[_articles objectAtIndex:0]).added;
				_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, offset);
			}
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
					if (vo.source_id > 0) {
						height = 220;
						CGSize size;
						
						if (vo.type_id > 1) {
							height += 270.0 * vo.imgRatio;
							height += 20;
						}
						
						size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
						height += size.height;
						
						if ([vo.affiliateURL length] > 0)
							height += 48;
						
						if (vo.type_id > 4) {
							height += 202;
							offset += 20;
						}
						
					} else {
						height = 59;
					}
					
					offset += height;
					tot++;
				}
				
				for (SNArticleItemView_iPhone *articleItemView in _cardViews) {
					[UIView animateWithDuration:0.5 animations:^(void) {
						articleItemView.frame = CGRectMake(0.0, articleItemView.frame.origin.y + offset, articleItemView.frame.size.width, articleItemView.frame.size.height);
					}];
				}
				
				int cnt = 0;
				offset = 60;
				
				NSMutableArray *articleList = [NSMutableArray array];
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					
					if (vo != nil)
						[articleList addObject:vo];
					
					int height;
					if (vo.source_id > 0) {
						height = 220;
						CGSize size;
						
						if (vo.type_id > 1) {
							height += 270.0 * vo.imgRatio;
							height += 20;
						}
						
						size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
						height += size.height;
						
						if (vo.type_id > 4) {
							height += 202;
						}
						
					} else {
						height = 59;
					}
					
					SNArticleItemView_iPhone *articleItemView = [[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, offset, _scrollView.frame.size.width, height) articleVO:vo];
					[_cardViews addObject:articleItemView];
					
					offset += height;
					cnt++;
				}
				
				for (SNArticleItemView_iPhone *itemView in _cardViews) {
					[_scrollView insertSubview:itemView atIndex:0];
				}
				
				
				NSMutableArray *updatedArticles = [NSMutableArray arrayWithArray:articleList];
				[updatedArticles addObjectsFromArray:_articles];
				_articles = [updatedArticles copy];
				_lastDate = ((SNArticleVO *)[_articles lastObject]).added;
				
				_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + offset);
			}
		}
		
		[self doneLoadingTableViewData];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SUBSCRIBED_LIST" object:nil];
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
