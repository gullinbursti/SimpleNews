//
//  SNArticleListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "SNArticleListViewController_iPhone.h"
#import "SNArticleCardView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNArticleVideoPlayerViewController_iPhone.h"

#import "SNFacebookCardView_iPhone.h"

@interface SNArticleListViewController_iPhone()
-(void)_goBack;
-(void)_prevCard;
-(void)_nextCard;
@end

@implementation SNArticleListViewController_iPhone

#define kImageScale 0.9

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startVideo:) name:@"START_VIDEO" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tagSearch:) name:@"TAG_SEARCH" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leaveArticles:) name:@"LEAVE_ARTICLES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_shareSheet:) name:@"SHARE_SHEET" object:nil];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_facebookShare:) name:@"FACEBOOK_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterShare:) name:@"TWITTER_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_emailShare:) name:@"EMAIL_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cancelShare:) name:@"CANCEL_SHARE" object:nil];
		
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		
		_isSwiping = NO;
		
		_shareSheetView = [[SNShareSheetView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 339.0)];
		[self.view addSubview:_shareSheetView];
	}
	return (self);
}

-(id)initAsMostRecent {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(id)initWithFollower:(int)follower_id {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", follower_id] forKey:@"followerID"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}


-(id)initWithFollowers {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[_articlesRequest setPostValue:[SNAppDelegate subscribedFollowers] forKey:@"followers"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}


-(id)initWithTag:(int)tag_id {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", tag_id] forKey:@"tagID"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}


-(id)initWithTags:(NSString *)tags {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
		[_articlesRequest setPostValue:tags forKey:@"tags"];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TAG_SEARCH" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LEAVE_ARTICLES" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHARE_SHEET" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FACEBOOK_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TWITTER_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"EMAIL_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"CANCEL_SHARE" object:nil];
	
	//[_articles release];
	[_overlayView release];
	[_cardHolderView release];
	
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	_cardHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_cardHolderView];
	
	//_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
	//[self.view addSubview:_overlayView];
	
	_greyGridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_greyGridButton.frame = CGRectMake(12.0, 12.0, 24.0, 24.0);
	[_greyGridButton setBackgroundImage:[UIImage imageNamed:@"gridIconGray_nonActive.png"] forState:UIControlStateNormal];
	[_greyGridButton setBackgroundImage:[UIImage imageNamed:@"gridIconGray_Active.png"] forState:UIControlStateHighlighted];
	[_greyGridButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_greyGridButton];
	
	_whiteGridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_whiteGridButton.frame = CGRectMake(12.0, 12.0, 24.0, 24.0);
	[_whiteGridButton setBackgroundImage:[UIImage imageNamed:@"gridIcon_nonActive.png"] forState:UIControlStateNormal];
	[_whiteGridButton setBackgroundImage:[UIImage imageNamed:@"gridIcon_Active.png"] forState:UIControlStateHighlighted];
	[_whiteGridButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_whiteGridButton];
	
	_greyShareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_greyShareButton.frame = CGRectMake(280.0, 12.0, 34.0, 34.0);
	[_greyShareButton setBackgroundImage:[UIImage imageNamed:@"shareIconGrey_nonActive.png"] forState:UIControlStateNormal];
	[_greyShareButton setBackgroundImage:[UIImage imageNamed:@"shareIconGrey_Active.png"] forState:UIControlStateHighlighted];
	[_greyShareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_greyShareButton];
	
	_whiteShareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_whiteShareButton.frame = CGRectMake(280.0, 12.0, 34.0, 34.0);
	[_whiteShareButton setBackgroundImage:[UIImage imageNamed:@"shareIcon_nonActive.png"] forState:UIControlStateNormal];
	[_whiteShareButton setBackgroundImage:[UIImage imageNamed:@"shareIcon_Active.png"] forState:UIControlStateHighlighted];
	[_whiteShareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_whiteShareButton];
	
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[_cardHolderView addGestureRecognizer:panRecognizer];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ARTICLES_RETURN" object:nil];	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SHEET" object:(SNArticleVO *)[_articles objectAtIndex:_cardIndex - 1]];
}

#pragma mark - Interaction handlers
-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
	NSLog(@"SWIPE @:(%f)", translatedPoint.x);
	
	if (!_isSwiping && (translatedPoint.x > 20.0 && abs(translatedPoint.y) < 20)) {
		[self _prevCard];
	}
		
	if (!_isSwiping && (translatedPoint.x < -20.0 && abs(translatedPoint.y) < 20)) {
		[self _nextCard];
	}
}

-(void)_prevCard {
	NSLog(@"PREV CARD");
	
	if (_cardIndex < [_cardViews count] - 1) {
		SNBaseArticleCardView_iPhone *cardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex + 1];
		SNBaseArticleCardView_iPhone *currentCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex];
		
		cardView.holderView.hidden = YES;
		cardView.scaledImgView.hidden = NO;
		
		_isSwiping = YES;
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			cardView.frame = CGRectMake(0.0, 0.0, cardView.frame.size.width, cardView.frame.size.height);
			currentCardView.frame = CGRectMake(self.view.frame.size.width, 0.0, currentCardView.frame.size.width, currentCardView.frame.size.height);
			
			_greyGridButton.frame = CGRectMake(-_greyGridButton.frame.size.width, -_greyGridButton.frame.size.height, 24.0, 24.0);
			_whiteGridButton.frame = CGRectMake(-_whiteGridButton.frame.size.width, -_whiteGridButton.frame.size.height, 24.0, 24.0);
			
			_greyShareButton.frame = CGRectMake(self.view.frame.size.width, -_greyShareButton.frame.size.height, 34.0, 34.0);
			_whiteShareButton.frame = CGRectMake(self.view.frame.size.width, -_whiteShareButton.frame.size.height, 34.0, 34.0);
			
		} completion:^(BOOL finished) {
			_isSwiping = NO;
			_cardIndex++;
			
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void) {
				NSLog(@"Article [%d/%d]", _cardIndex, [_articles count]);
				SNArticleVO *vo = (SNArticleVO *)[_articles objectAtIndex:_cardIndex - 1];
				
				if (vo.isDark) {
					_greyGridButton.frame = CGRectMake(12.0, 12.0, 24.0, 24.0);
					_greyShareButton.frame = CGRectMake(280.0, 12.0, 34.0, 34.0);
					
				} else {
					_whiteGridButton.frame = CGRectMake(12.0, 12.0, 24.0, 24.0);
					_whiteShareButton.frame = CGRectMake(280.0, 12.0, 34.0, 34.0);
				}
			} completion:nil];
		}];
		
		[UIView animateWithDuration:0.15 delay:0.25 options:UIViewAnimationCurveEaseInOut animations:^(void) {
			cardView.scaledImgView.frame = CGRectMake(0.0, 0.0, cardView.frame.size.width, cardView.frame.size.height);
			
		} completion:^(BOOL finished) {
			cardView.scaledImgView.hidden = YES;
			cardView.scaledImgView.frame = CGRectMake(((cardView.frame.size.width - (cardView.frame.size.width * kImageScale)) * 0.5), ((cardView.frame.size.height - (cardView.frame.size.height * kImageScale)) * 0.5), cardView.frame.size.width * kImageScale, cardView.frame.size.height * kImageScale);
			cardView.holderView.hidden = NO;
		}];
	}
}

-(void)_nextCard {
	NSLog(@"NEXT CARD");
	
	if (_cardIndex > 1) {
		SNBaseArticleCardView_iPhone *cardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex];
		SNBaseArticleCardView_iPhone *nextCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex - 1];
		
		nextCardView.holderView.hidden = YES;
		nextCardView.scaledImgView.hidden = NO;
		nextCardView.frame = CGRectMake(0.0, 0.0, nextCardView.frame.size.width, nextCardView.frame.size.height);
		
		_isSwiping = YES;
		[UIView animateWithDuration:0.33 animations:^(void) {
			cardView.frame = CGRectMake(-self.view.frame.size.width, 0.0, cardView.frame.size.width, cardView.frame.size.height);
			
			_greyGridButton.frame = CGRectMake(-_greyGridButton.frame.size.width, -_greyGridButton.frame.size.height, 24.0, 24.0);
			_whiteGridButton.frame = CGRectMake(-_whiteGridButton.frame.size.width, -_whiteGridButton.frame.size.height, 24.0, 24.0);
			
			_greyShareButton.frame = CGRectMake(self.view.frame.size.width, -_greyShareButton.frame.size.height, 34.0, 34.0);
			_whiteShareButton.frame = CGRectMake(self.view.frame.size.width, -_whiteShareButton.frame.size.height, 34.0, 34.0);
			
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.25 animations:^(void) {
				NSLog(@"Article [%d/%d]", _cardIndex, [_articles count]);
				SNArticleVO *vo = (SNArticleVO *)[_articles objectAtIndex:_cardIndex - 1];
				
				if (vo.isDark) {
					_greyGridButton.frame = CGRectMake(12.0, 12.0, 24.0, 24.0);
					_greyShareButton.frame = CGRectMake(280.0, 12.0, 34.0, 34.0);
					
				} else {
					_whiteGridButton.frame = CGRectMake(12.0, 12.0, 24.0, 24.0);
					_whiteShareButton.frame = CGRectMake(280.0, 12.0, 34.0, 34.0);
				}
			}];
			
			_isSwiping = NO;
			_cardIndex--;
		}];
		
		
		[UIView animateWithDuration:0.15 delay:0.25 options:UIViewAnimationCurveEaseInOut animations:^(void) {
			nextCardView.scaledImgView.frame = CGRectMake(0.0, 0.0, cardView.frame.size.width, cardView.frame.size.height);
			
		} completion:^(BOOL finished) {
			nextCardView.scaledImgView.hidden = YES;
			nextCardView.scaledImgView.frame = CGRectMake(((nextCardView.frame.size.width - (nextCardView.frame.size.width * kImageScale)) * 0.5), ((nextCardView.frame.size.height - (nextCardView.frame.size.height * kImageScale)) * 0.5), nextCardView.frame.size.width * kImageScale, nextCardView.frame.size.height * kImageScale);
			nextCardView.holderView.hidden = NO;
		}];
	}
}


-(void)_introFirstCard {
	SNArticleCardView_iPhone *articleCardView = (SNArticleCardView_iPhone *)[_cardViews lastObject];
	
	[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
		articleCardView.scaledImgView.frame = CGRectMake(0.0, 0.0, articleCardView.frame.size.width, articleCardView.frame.size.height);
		
	} completion:^(BOOL finished) {
		articleCardView.scaledImgView.hidden = YES;
		articleCardView.scaledImgView.frame = CGRectMake(((articleCardView.frame.size.width - (articleCardView.frame.size.width * kImageScale)) * 0.5), ((articleCardView.frame.size.height - (articleCardView.frame.size.height * kImageScale)) * 0.5), articleCardView.frame.size.width * kImageScale, articleCardView.frame.size.height * kImageScale);
		articleCardView.holderView.hidden = NO;
	}];
}



#pragma mark - Notification handlers
-(void)_startVideo:(NSNotification *)notification {
	UIView *blackMatteView = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
	[blackMatteView setBackgroundColor:[UIColor blackColor]];
	blackMatteView.alpha = 0.0;
	[self.view addSubview:blackMatteView];
	
	[UIView animateWithDuration:1.0 animations:^(void) {
		blackMatteView.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		[blackMatteView removeFromSuperview];
		
		SNArticleVideoPlayerViewController_iPhone *articleListViewController = [[[SNArticleVideoPlayerViewController_iPhone alloc] init] autorelease];
		UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:articleListViewController] autorelease];
		
		[navigationController setNavigationBarHidden:YES];
		[self.navigationController presentModalViewController:navigationController animated:NO];
	}];
	
	
//	SNArticleVideoPlayerViewController_iPhone *articleListViewController = [[[SNArticleVideoPlayerViewController_iPhone alloc] init] autorelease];
//	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:articleListViewController] autorelease];
//	
//	[navigationController setNavigationBarHidden:YES];
//	[self.navigationController presentModalViewController:navigationController animated:YES];
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
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_shareSheetView.frame = CGRectMake(0.0, self.view.frame.size.height - _shareSheetView.frame.size.height, _shareSheetView.frame.size.width, _shareSheetView.frame.size.height);
	}];
}


-(void)_facebookShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	if (![[(SNAppDelegate *)[UIApplication sharedApplication].delegate facebook] isSessionValid]) {
		[[(SNAppDelegate *)[UIApplication sharedApplication].delegate facebook] authorize:nil];
	} else {
	}
	
	[[(SNAppDelegate *)[UIApplication sharedApplication].delegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"me/feed"] andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:vo.title, @"feed", nil] andHttpMethod:@"POST" andDelegate:self];
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
		NSString *msg; 
		
		if (result == TWTweetComposeViewControllerResultDone)
			msg = @"Tweet compostion completed.";
		
		else if (result == TWTweetComposeViewControllerResultCancelled)
			msg = @"Tweet composition canceled.";
		
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tweet Status" message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
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
		_shareSheetView.frame = CGRectMake(0.0, self.view.frame.size.height, _shareSheetView.frame.size.width, _shareSheetView.frame.size.height);
	}];
}

//CGAffineTransform transform = scaleCardView.transform;
//scaleCardView.transform = CGAffineTransformScale(transform, 1.18f, 1.18f);


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


#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	//NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	// This callback can be a result of getting the user's basic
	// information or getting the user's permissions.
	if ([result objectForKey:@"name"]) {
		// If basic information callback, set the UI objects to
		// display this.
		//		nameLabel.text = [result objectForKey:@"name"];
		// Get the profile image
		UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"pic"]]]];
		
		// Resize, crop the image to make sure it is square and renders
		// well on Retina display
		float ratio;
		float delta;
		float px = 100; // Double the pixels of the UIImageView (to render on Retina)
		CGPoint offset;
		CGSize size = image.size;
		if (size.width > size.height) {
			ratio = px / size.width;
			delta = (ratio*size.width - ratio*size.height);
			offset = CGPointMake(delta/2, 0);
		} else {
			ratio = px / size.height;
			delta = (ratio*size.height - ratio*size.width);
			offset = CGPointMake(0, delta/2);
		}
		CGRect clipRect = CGRectMake(-offset.x, -offset.y,
											  (ratio * size.width) + delta,
											  (ratio * size.height) + delta);
		UIGraphicsBeginImageContext(CGSizeMake(px, px));
		UIRectClip(clipRect);
		[image drawInRect:clipRect];
		UIImage *imgThumb =   UIGraphicsGetImageFromCurrentImageContext();
		[imgThumb retain];
		
		//		[profilePhotoImageView setImage:imgThumb];
		//		[self apiGraphUserPermissions];
	} else {
		// Processing permissions information
		//		HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
		//		[delegate setUserPermissions:[[result objectForKey:@"data"] objectAtIndex:0]];
	}
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
	NSLog(@"Err code: %d", [error code]);
}




#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleListViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedArticles = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *articleList = [NSMutableArray array];
			_cardViews = [NSMutableArray new];
			
			SNArticleCardView_iPhone *followerItemView = [[[SNArticleCardView_iPhone alloc] initWithFrame:CGRectMake(0.0, 50.0, 80.0, 80.0) articleVO:nil] autorelease];
			[_cardViews addObject:followerItemView];
			
			int tot = 0;
			for (NSDictionary *serverArticle in parsedArticles) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
				
				NSLog(@"ARTICLE \"%@\"", vo.title);
				
				if (vo != nil)
					[articleList addObject:vo];
				
				
				SNArticleCardView_iPhone *articleCardView = [[[SNArticleCardView_iPhone alloc] initWithFrame:_cardHolderView.frame articleVO:vo] autorelease];
				[_cardViews addObject:(SNBaseArticleCardView_iPhone *)articleCardView];
				tot++;
			}
			
			_articles = [articleList retain];
			
			for (SNArticleCardView_iPhone *cardView in _cardViews) {
				[_cardHolderView addSubview:cardView];
			}
						
//			SNFacebookCardView_iPhone *facebookCardView = [[[SNFacebookCardView_iPhone alloc] initWithFrame:self.view.frame] autorelease];
//			[_cardViews insertObject:(SNBaseArticleCardView_iPhone *)facebookCardView atIndex:[_cardViews count] - 3];
//			[_cardHolderView addSubview:facebookCardView];
//			
			_cardIndex = [_cardViews count] - 1;
			[self performSelector:@selector(_introFirstCard) withObject:nil afterDelay:0.125];
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
