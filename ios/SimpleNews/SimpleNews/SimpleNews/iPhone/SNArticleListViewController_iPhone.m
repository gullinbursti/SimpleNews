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
#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNTweetVO.h"

#import "SNWebPageViewController_iPhone.h"

@interface SNArticleListViewController_iPhone()
-(void)_goBack;
@end

@implementation SNArticleListViewController_iPhone

#define kImageScale 0.9

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showComments:) name:@"SHOW_COMMENTS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leaveArticles:) name:@"LEAVE_ARTICLES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_shareSheet:) name:@"SHARE_SHEET" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_facebookShare:) name:@"FACEBOOK_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterShare:) name:@"TWITTER_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_emailShare:) name:@"EMAIL_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cancelShare:) name:@"CANCEL_SHARE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleDetails:) name:@"SHOW_ARTICLE_DETAILS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTweetPage:) name:@"SHOW_TWEET_PAGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSourcePage:) name:@"SHOW_SOURCE_PAGE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterTimeline:) name:@"TWITTER_TIMELINE" object:nil];
		
		_isFlipped = NO;
		
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
	
	[_articlesRequest release];;
	
	[_overlayView release];
	[_shareSheetView release];
	[_blackMatteView release];
	
	[super dealloc];
}


#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	SNHeaderView_iPhone *headerView = [[[SNHeaderView_iPhone alloc] initWithTitle:_vo.list_name] autorelease];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	backButton.frame = CGRectMake(4.0, 4.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIButton *flipButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	flipButton.frame = CGRectMake(272.0, 4.0, 44.0, 44.0);
	[flipButton setBackgroundImage:[UIImage imageNamed:@"flipListButtonHeader_nonActive.png"] forState:UIControlStateNormal];
	[flipButton setBackgroundImage:[UIImage imageNamed:@"flipListButtonHeader_Active.png"] forState:UIControlStateHighlighted];
	[flipButton addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:flipButton];
	
	_doneButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
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
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.view.frame];
	[_blackMatteView setBackgroundColor:[UIColor blackColor]];
	_blackMatteView.alpha = 0.0;
	[self.view addSubview:_blackMatteView];

	_shareSheetView = [[SNShareSheetView_iPhone alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 339.0)];
	[self.view addSubview:_shareSheetView];
	
	
	_flippedView = [[SNFlippedArticleView_iPhone alloc] initWithFrame:self.view.frame listVO:_vo];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goFlip {
	_isFlipped = !_isFlipped;	
	
	if (_isFlipped) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[UIView commitAnimations];
		[self.view addSubview:_flippedView];
		
		[UIView animateWithDuration:0.25 delay:0.4 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
			[self.view addSubview:_doneButton];
			_doneButton.alpha = 1.0;
		} completion:nil];
		
					
	} else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_doneButton.alpha = 0.0;
		
		} completion:^(BOOL finished) {
			[_doneButton removeFromSuperview];
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
			[UIView commitAnimations];
			[_flippedView removeFromSuperview];
		}];
	}
}

#pragma mark - Notification handlers
-(void)_leaveArticles:(NSNotification *)notification {
	[self _goBack];
}

-(void)_showComments:(NSNotification *)notification {
	[self.navigationController pushViewController:[[[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object] listID:_vo.list_id] autorelease] animated:YES];
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

-(void)_showArticleDetails:(NSNotification *)notification {
	SNArticleDetailsViewController_iPhone *articleDetailsViewController = [[[SNArticleDetailsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:articleDetailsViewController animated:YES];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showTweetPage:(NSNotification *)notification {
	NSString *handle = [[notification object] objectForKey:@"handle"];
	NSString *tweetID = [[notification object] objectForKey:@"tweetID"];
	
	SNWebPageViewController_iPhone *webPageViewController = [[[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/status/%@/", handle, tweetID]] title:[NSString stringWithFormat:@"@%@", handle]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showSourcePage:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[notification object]] title:@""] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:webPageViewController animated:YES];
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
				int offset = 0;
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					
					//NSLog(@"ARTICLE \"%@\"", vo.title);
					
					if (vo != nil)
						[articleList addObject:vo];
					
					int height = 150;
					CGSize size;
					
					size = [vo.tweetMessage sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(252.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height;
					
					height += 252.0 * vo.imgRatio;
					
					size = [vo.title sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(252.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height;
					
					size = [vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(252.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
					height += size.height;
					
					if (vo.type_id > 4)
						height += 196;
					
					else 
						height += 16;
					
					SNArticleItemView_iPhone *articleItemView = [[[SNArticleItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, offset, _scrollView.frame.size.width, height) articleVO:vo] autorelease];
					[_cardViews addObject:articleItemView];
					
					offset += height;
					tot++;
				}
				
				_articles = [articleList retain];
				
				for (SNArticleItemView_iPhone *itemView in _cardViews) {
					[_scrollView addSubview:itemView];
				}
				
				_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, offset);
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
