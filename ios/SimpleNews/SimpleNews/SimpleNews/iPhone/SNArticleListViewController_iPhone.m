//
//  SNArticleListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <Twitter/Twitter.h>
#import "SNGraphCaller.h"

#import "SNArticleListViewController_iPhone.h"
#import "SNArticleItemView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNTweetVO.h"

#import "SNOptionsPageViewController.h"

@interface SNArticleListViewController_iPhone()
-(void)_goBack;
@end

@implementation SNArticleListViewController_iPhone

#define kImageScale 0.9

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startVideo:) name:@"START_VIDEO" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoStarted:) name:@"VIDEO_STARTED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tagSearch:) name:@"TAG_SEARCH" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leaveArticles:) name:@"LEAVE_ARTICLES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_shareSheet:) name:@"SHARE_SHEET" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_facebookShare:) name:@"FACEBOOK_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterShare:) name:@"TWITTER_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_emailShare:) name:@"EMAIL_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cancelShare:) name:@"CANCEL_SHARE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTweetPage:) name:@"SHOW_TWEET_PAGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSourcePage:) name:@"SHOW_SOURCE_PAGE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showReactionProfile:) name:@"SHOW_REACTION_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showReactionPage:) name:@"SHOW_REACTION_PAGE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterTimeline:) name:@"TWITTER_TIMELINE" object:nil];
		
		_isLastCard = NO;
		
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		_timelineTweets = [NSMutableArray new];
	}
	
	return (self);
}


-(id)initWithListVO:(SNListVO *)vo {
	if ((self = [self init])) {
		_vo = vo;
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_VIDEO" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEO_ENDED" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TAG_SEARCH" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LEAVE_ARTICLES" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHARE_SHEET" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FACEBOOK_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TWITTER_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"EMAIL_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"CANCEL_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_TIMER" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOP_TIMER" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_TWITTER_PROFILE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_TWEET_PAGE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_SOURCE_PAGE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_REACTION_PROFILE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_REACTION_PAGE" object:nil];
	
	[_articlesRequest release];;
	
	[_overlayView release];
	[_cardHolderView release];
	[_shareSheetView release];
	[_blackMatteView release];
	
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor colorWithWhite:0.941 alpha:1.0]];
	
	UIButton *backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	backButton.frame = CGRectMake(4.0, 4.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIButton *flipButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	flipButton.frame = CGRectMake(272.0, 4.0, 44.0, 44.0);
	[flipButton setBackgroundImage:[UIImage imageNamed:@"flipListButtonHeader_nonActive.png"] forState:UIControlStateNormal];
	[flipButton setBackgroundImage:[UIImage imageNamed:@"flipListButtonHeader_Active.png"] forState:UIControlStateHighlighted];
	[flipButton addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:flipButton];
	
	UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(64.0, 12.0, 192.0, 24)] autorelease];
	titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:18];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = _vo.list_name;
	[self.view addSubview:titleLabel];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 53.0, self.view.frame.size.width, self.view.frame.size.height - 53.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_scrollView setBackgroundColor:[UIColor whiteColor]];
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:_scrollView];
	
	
	_cardHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	//[self.view addSubview:_cardHolderView];
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.view.frame];
	[_blackMatteView setBackgroundColor:[UIColor blackColor]];
	_blackMatteView.alpha = 0.0;
	//[self.view addSubview:_blackMatteView];
	
	_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:self.view.frame];
	_videoPlayerView.hidden = YES;
	//[self.view addSubview:_videoPlayerView];
	
	

	_shareSheetView = [[SNShareSheetView_iPhone alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 339.0)];
	[self.view addSubview:_shareSheetView];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	UISwipeGestureRecognizer *swipeRtRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_prevCard:)];
	swipeRtRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[_cardHolderView addGestureRecognizer:swipeRtRecognizer];
	//[swipeRtRecognizer release];
	
	UISwipeGestureRecognizer *swipeLtRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_nextCard:)];
	swipeLtRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[_cardHolderView addGestureRecognizer:swipeLtRecognizer];
	//[swipeLtRecognizer release];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ARTICLES_RETURN" object:nil];	
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Interaction handlers
/*
 -(void)_introFirstCard {
	SNArticleCardView_iPhone *articleCardView = (SNArticleCardView_iPhone *)[_cardViews lastObject];
	
	CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	zoomAnimation.beginTime = CACurrentMediaTime();
	zoomAnimation.toValue = [NSNumber numberWithDouble:1.0];
	zoomAnimation.duration = 0.15;
	zoomAnimation.fillMode = kCAFillModeForwards;
	zoomAnimation.removedOnCompletion = NO;
	zoomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	[articleCardView.bgView.layer addAnimation:zoomAnimation forKey:@"zoomAnimation"];
	
	[articleCardView introContent];
	
	NSMutableArray *tweets = [NSMutableArray new];
	SNArticleVO *articleVO = (SNArticleVO *)[_articles objectAtIndex:_cardIndex];
	for (SNTweetVO *tweetVO in _timelineTweets) {
		if ([tweetVO.content rangeOfString:articleVO.article_url].location > 0 || [tweetVO.content rangeOfString:articleVO.short_url].location > 0) {
			[tweets addObject:tweetVO];
		}
	}
	
	[articleCardView setTweets:tweets];
}

-(void)_prevCard:(id)sender {
	NSLog(@"PREV CARD");
	
	if (_cardIndex < [_cardViews count] - 1) {
				
		SNBaseArticleCardView_iPhone *previousCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex + 1];
		SNBaseArticleCardView_iPhone *currentCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex];

		[UIView animateWithDuration:0.33 animations:^(void) {
			previousCardView.frame = CGRectMake(0.0, 0.0, previousCardView.frame.size.width, previousCardView.frame.size.height);
			currentCardView.frame = CGRectMake(self.view.frame.size.width, 0.0, currentCardView.frame.size.width, currentCardView.frame.size.height);
			
		} completion:^(BOOL finished) {
			
			[previousCardView introContent];
			[currentCardView resetContent];
			
			_cardIndex++;
			_isLastCard = NO;
			
		}];
			
	} else
		_isLastCard = YES;
}

-(void)_nextCard:(id)sender {
	NSLog(@"NEXT CARD");
	
	if (_cardIndex > 0) {
				
		SNBaseArticleCardView_iPhone *currentCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex];
		SNBaseArticleCardView_iPhone *nextCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex - 1];
		
		nextCardView.frame = CGRectMake(0.0, 0.0, nextCardView.frame.size.width, nextCardView.frame.size.height);
		
		CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		zoomAnimation.beginTime = CACurrentMediaTime() + 0.25;
		zoomAnimation.toValue = [NSNumber numberWithDouble:1.0];
		zoomAnimation.duration = 0.15;
		zoomAnimation.fillMode = kCAFillModeForwards;
		zoomAnimation.removedOnCompletion = NO;
		zoomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		[nextCardView.bgView.layer addAnimation:zoomAnimation forKey:@"zoomAnimation"];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			currentCardView.frame = CGRectMake(-self.view.frame.size.width, 0.0, currentCardView.frame.size.width, currentCardView.frame.size.height);
			
		} completion:^(BOOL finished) {
			
			[currentCardView resetContent];
			[nextCardView introContent];
			_cardIndex--;
			_isLastCard = NO;
		}];
				
	} else
		_isLastCard = YES;
}
 */


#pragma mark - Notification handlers
-(void)_startVideo:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	_videoPlayerView.hidden = NO;
	[_videoPlayerView changeArticleVO:vo];
}

-(void)_videoStarted:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationCurveLinear animations:^(void) {
		_blackMatteView.alpha = 1.0;
	} completion:nil];
}

-(void)_videoEnded:(NSNotification *)notification {
	
	_videoPlayerView.hidden = YES;
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:nil];
}

-(void)_tagSearch:(NSNotification *)notification {
	[self _goBack];
}

-(void)_leaveArticles:(NSNotification *)notification {
	[self _goBack];
}

-(void)_shareSheet:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	[_shareSheetView setVo:vo];
	
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_blackMatteView.alpha = 0.67;
		_shareSheetView.frame = CGRectMake(0.0, self.view.frame.size.height - _shareSheetView.frame.size.height, _shareSheetView.frame.size.width, _shareSheetView.frame.size.height);
	
	} completion:^(BOOL finished) {
	}];
}


-(void)_facebookShare:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CANCEL_SHARE" object:nil];	
}
-(void)_twitterShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	TWTweetComposeViewController *twitter = [[[TWTweetComposeViewController alloc] init] autorelease];
	
	//[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
	[twitter addURL:[NSURL URLWithString:[NSString stringWithString:[NSString stringWithFormat:@"http://assemb.ly/tweets?id=%@", vo.tweet_id]]]];
	[twitter setInitialText:[NSString stringWithFormat:@"via Assembly - %@", vo.title]];
	
	[self presentModalViewController:twitter animated:YES];
	
	twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
		
		
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

-(void)_emailShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
		mfViewController.mailComposeDelegate = self;
		[mfViewController setSubject:[NSString stringWithFormat:@"Assembly - %@", vo.title]];
		[mfViewController setMessageBody:vo.content isHTML:NO];
		
		[self presentViewController:mfViewController animated:YES completion:nil];
		[mfViewController release];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"Your phone is not currently configured to send mail." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
		
		[alert show];
		[alert release];
	}
}
-(void)_cancelShare:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_blackMatteView.alpha = 0.0;
		_shareSheetView.frame = CGRectMake(0.0, self.view.frame.size.height, _shareSheetView.frame.size.width, _shareSheetView.frame.size.height);
	
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
	}];
}

-(void)_twitterTimeline:(NSNotification *)notification {
	_timelineTweets = (NSMutableArray *)[notification object];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNOptionsPageViewController *tweetPageViewController = [[[SNOptionsPageViewController alloc] initWithURL:[NSURL URLWithString:[notification object]]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:tweetPageViewController animated:YES];
}

-(void)_showTweetPage:(NSNotification *)notification {
	SNOptionsPageViewController *tweetPageViewController = [[[SNOptionsPageViewController alloc] initWithURL:[NSURL URLWithString:[notification object]]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:tweetPageViewController animated:YES];
}

-(void)_showSourcePage:(NSNotification *)notification {
	SNOptionsPageViewController *tweetPageViewController = [[[SNOptionsPageViewController alloc] initWithURL:[NSURL URLWithString:[notification object]]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:tweetPageViewController animated:YES];
}

-(void)_showReactionPage:(NSNotification *)notification {
	SNOptionsPageViewController *tweetPageViewController = [[[SNOptionsPageViewController alloc] initWithURL:[NSURL URLWithString:[notification object]]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:tweetPageViewController animated:YES];
}

-(void)_showReactionProfile:(NSNotification *)notification {
	SNOptionsPageViewController *tweetPageViewController = [[[SNOptionsPageViewController alloc] initWithURL:[NSURL URLWithString:[notification object]]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:tweetPageViewController animated:YES];
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {	
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
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
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
	
	[alert release];
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
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					
					//NSLog(@"ARTICLE \"%@\"", vo.title);
					
					if (vo != nil)
						[articleList addObject:vo];
					
					SNArticleItemView_iPhone *articleItemView = [[[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, 200.0 * tot, _scrollView.frame.size.width, 200.0) articleVO:vo] autorelease];
					[_cardViews addObject:articleItemView];
					//SNArticleCardView_iPhone *articleCardView = [[[SNArticleCardView_iPhone alloc] initWithFrame:_cardHolderView.frame articleVO:vo listID:_list_id] autorelease];
					
					tot++;
				}
				
				_articles = [articleList retain];
				
				for (SNArticleItemView_iPhone *itemView in _cardViews) {
					[_scrollView addSubview:itemView];
				}
				
				_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, 200.0 * tot);
			}
		}	
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	if (request == _articlesRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}


/*
 -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */






@end
