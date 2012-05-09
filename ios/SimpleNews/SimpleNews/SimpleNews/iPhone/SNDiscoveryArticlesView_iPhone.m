//
//  SNDiscoveryArticlesView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "GANTracker.h"
#import "ImageFilter.h"

#import "SNDiscoveryArticlesView_iPhone.h"

#import "SNArticleListViewController_iPhone.h"
#import "SNDiscoveryArticleCardView_iPhone.h"
#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavTitleView.h"
#import "SNNavListBtnView.h"
#import "SNNavLogoBtnView.h"
#import "SNAppDelegate.h"
#import "SNTweetVO.h"

#import "SNWebPageViewController_iPhone.h"

@implementation SNDiscoveryArticlesView_iPhone

#define kImageScale 0.9

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showComments:) name:@"SHOW_COMMENTS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leaveArticles:) name:@"LEAVE_ARTICLES" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFullscreenMedia:) name:@"SHOW_FULLSCREEN_MEDIA" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideFullscreenMedia:) name:@"HIDE_FULLSCREEN_MEDIA" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_readLater:) name:@"READ_LATER" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleDetails:) name:@"SHOW_ARTICLE_DETAILS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSourcePage:) name:@"SHOW_SOURCE_PAGE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterTimeline:) name:@"TWITTER_TIMELINE" object:nil];
		
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		_timelineTweets = [NSMutableArray new];
	}
	
	return (self);
}


-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [self initWithFrame:frame])) {
		_vo = vo;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		bgImgView.image = [UIImage imageNamed:@"timelineBG.png"];
		[self addSubview:bgImgView];
		
		_articlesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/lists/%d", _vo.list_id] withError:&error])
			NSLog(@"error in trackPageview");
		
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 49.0, self.frame.size.width, self.frame.size.height - 49.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = YES;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
		[self addSubview:_scrollView];
		
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		_refreshHeaderView.delegate = self;
		[_scrollView addSubview:_refreshHeaderView];
		[_refreshHeaderView refreshLastUpdatedDate];
		
		SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.list_name];
		[self addSubview:headerView];
		
		SNNavListBtnView *listBtnView = [[SNNavListBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
		[[listBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:listBtnView];
		
		SNNavLogoBtnView *logoBtnView = [[SNNavLogoBtnView alloc] initWithFrame:CGRectMake(276.0, 0.0, 44.0, 44.0)];
		[[logoBtnView btn] addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:logoBtnView];
		
		
		_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_doneButton.frame = CGRectMake(250.0, 3.0, 64.0, 48.0);
		[_doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive.png"] forState:UIControlStateNormal];
		[_doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active.png"] forState:UIControlStateHighlighted];
		_doneButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11.0];
		_doneButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[_doneButton setTitle:@"Done" forState:UIControlStateNormal];
		[_doneButton addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
		_doneButton.alpha = 0.0;
		
		_blackMatteView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[_blackMatteView setBackgroundColor:[UIColor blackColor]];
		_blackMatteView.alpha = 0.0;
		[self addSubview:_blackMatteView];
		
		UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
		[self addSubview:overlayImgView];
	}
	
	return (self);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	if (CGRectContainsPoint(_videoPlayerView.frame, touchPoint))
		[_videoPlayerView toggleControls];//NSLog(@"TOUCHED:(%f, %f)", touchPoint.x, touchPoint.y);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LEAVE_ARTICLES" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_TIMER" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOP_TIMER" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_TWITTER_PROFILE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_TWEET_PAGE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_SOURCE_PAGE" object:nil];
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
}

-(void)_goFlip {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_SOURCES" object:nil];	
}

#pragma mark - Notification handlers
-(void)_leaveArticles:(NSNotification *)notification {
	[self _goBack];
}

-(void)_showFullscreenMedia:(NSNotification *)notification {
	NSDictionary *dict = [notification object];
	
	SNArticleVO *vo = [dict objectForKey:@"VO"];
	float offset = [[dict objectForKey:@"offset"] floatValue];
	CGRect frame = [[dict objectForKey:@"frame"] CGRectValue];
	NSString *type = [dict objectForKey:@"type"];
	
	frame.origin.y = 49.0 + frame.origin.y + offset - _scrollView.contentOffset.y;
	_fullscreenFrame = frame;
	
	if ([type isEqualToString:@"photo"]) {
		_fullscreenImgView = [[EGOImageView alloc] initWithFrame:frame];
		_fullscreenImgView.delegate = self;
		_fullscreenImgView.imageURL = [NSURL URLWithString:vo.bgImage_url];
		_fullscreenImgView.userInteractionEnabled = YES;
		[self addSubview:_fullscreenImgView];
		
	} else if ([type isEqualToString:@"video"]) {
		_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, 270.0, 202.0) articleVO:vo];
		_videoPlayerView.frame = frame;
		[self addSubview:_videoPlayerView];
	}
	
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_blackMatteView.alpha = 0.95;
		
		if ([type isEqualToString:@"photo"])
			_fullscreenImgView.frame = CGRectMake(0.0, (self.frame.size.height - (self.frame.size.width * vo.imgRatio)) * 0.5, self.frame.size.width, self.frame.size.width * vo.imgRatio);
		
		else
			_videoPlayerView.frame = CGRectMake(0.0, (self.frame.size.height - 240.0) * 0.5, self.frame.size.width, 240.0);
		
		
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
		_videoPlayerView.frame = _fullscreenFrame;
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
	//[self.navigationController pushViewController:[[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object] listID:_vo.list_id] animated:YES];
}

-(void)_readLater:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CANCEL_SHARE" object:nil];	
}

-(void)_twitterTimeline:(NSNotification *)notification {
	_timelineTweets = (NSMutableArray *)[notification object];
}

-(void)_showArticleDetails:(NSNotification *)notification {
	//SNArticleDetailsViewController_iPhone *articleDetailsViewController = [[SNArticleDetailsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object]];
	//[self.navigationController setNavigationBarHidden:YES];
	//[self.navigationController pushViewController:articleDetailsViewController animated:YES];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	//SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]];
	//[self.navigationController setNavigationBarHidden:YES];
	//[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showSourcePage:(NSNotification *)notification {
	//SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[notification object]] title:@""];
	//[self.navigationController setNavigationBarHidden:YES];
	//[self.navigationController pushViewController:webPageViewController animated:YES];
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

// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_paginationView updToPage:round(scrollView.contentOffset.x / self.frame.size.width)];
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

#pragma mark - MailComposeViewController Delegates
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	
	switch (result) {
		case MFMailComposeResultCancelled:
			alert.message = @"Message Canceled";
			break;
			
		case MFMailComposeResultSaved:
			alert.message = @"Message Saved";
			[alert show];
			break;
			
		case MFMailComposeResultSent:
			alert.message = @"Message Sent";
			break;
			
		case MFMailComposeResultFailed:
			alert.message = @"Message Failed";
			[alert show];
			break;
			
		default:
			alert.message = @"Message Not Sent";
			[alert show];
			break;
	}
	
	//[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image View delegates
-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	NSLog(@"LOADED [%@]", imageView.imageURL);
	UIImage *img = imageView.image;
	imageView.image = [img saturate:(1 + 1 - 0.5)];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	//NSLog(@"SNDiscoveryArticlesView_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
				//int offset = 60;
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					
					//NSLog(@"ARTICLE \"%@\"", vo.title);
					
					if (vo != nil)
						[articleList addObject:vo];
					
					int height = 220;
					CGSize size;
					
					if (vo.type_id > 1) {
						height += 270.0 * vo.imgRatio;
						height += 20;
					}
					
					size = [vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height;
					
					if (vo.type_id > 4)
						height += 222;
					
					
					SNDiscoveryArticleCardView_iPhone *articleItemView = [[SNDiscoveryArticleCardView_iPhone alloc] initWithFrame:CGRectMake(tot * 320.0, 0.0, _scrollView.frame.size.width, height) articleVO:vo];
					[_cardViews addObject:articleItemView];
					
					tot++;					
				}
				
				_articles = [articleList copy];
				
				for (SNDiscoveryArticleCardView_iPhone *itemView in _cardViews) {
					[_scrollView addSubview:itemView];
				}
				
				_lastDate = ((SNArticleVO *)[_articles objectAtIndex:0]).added;
				_scrollView.contentSize = CGSizeMake(tot * 320.0, self.frame.size.height - 49.0);
				
				_paginationView = [[SNPaginationView alloc] initWithTotal:[_cardViews count] coords:CGPointMake(160.0, 460.0)];
				[self addSubview:_paginationView];
			}
		}	
		
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
				
				for (SNDiscoveryArticleCardView_iPhone *articleItemView in _cardViews) {
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
					
					SNDiscoveryArticleCardView_iPhone *articleItemView = [[SNDiscoveryArticleCardView_iPhone alloc] initWithFrame:CGRectMake(0.0, offset, _scrollView.frame.size.width, height) articleVO:vo];
					[_cardViews addObject:articleItemView];
					
					offset += height;
					cnt++;
				}
				
				for (SNDiscoveryArticleCardView_iPhone *itemView in _cardViews) {
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
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	if (request == _articlesRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}

@end