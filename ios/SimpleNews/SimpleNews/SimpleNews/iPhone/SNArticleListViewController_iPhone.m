//
//  SNArticleListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleListViewController_iPhone.h"
#import "SNArticleCardView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNArticleVideoPlayerViewController_iPhone.h"

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
		
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		
		_isSwiping = NO;
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
	
	//[_articles release];
	[_overlayView release];
	[_gridButton release];
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
	
	_gridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_gridButton.frame = CGRectMake(4.0, 4.0, 34.0, 34.0);
	[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridButton_nonActive.png"] forState:UIControlStateNormal];
	[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridButton_Active.png"] forState:UIControlStateHighlighted];
	[_gridButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_gridButton];
	
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
		SNArticleCardView_iPhone *cardView = (SNArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex + 1];
		SNArticleCardView_iPhone *currentCardView = (SNArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex];
		
		cardView.holderView.hidden = YES;
		cardView.scaledImgView.hidden = NO;
		
		_isSwiping = YES;
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			cardView.frame = CGRectMake(0.0, 0.0, cardView.frame.size.width, cardView.frame.size.height);
			currentCardView.frame = CGRectMake(self.view.frame.size.width, 0.0, currentCardView.frame.size.width, currentCardView.frame.size.height);
			
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
				cardView.scaledImgView.frame = CGRectMake(0.0, 0.0, cardView.frame.size.width, cardView.frame.size.height);
				
			} completion:^(BOOL finished) {
				cardView.scaledImgView.hidden = YES;
				cardView.scaledImgView.frame = CGRectMake(((cardView.frame.size.width - (cardView.frame.size.width * kImageScale)) * 0.5), ((cardView.frame.size.height - (cardView.frame.size.height * kImageScale)) * 0.5), cardView.frame.size.width * kImageScale, cardView.frame.size.height * kImageScale);
				cardView.holderView.hidden = NO;
			}];
			
			_isSwiping = NO;
			_cardIndex++;
		}];
	}
}

-(void)_nextCard {
	NSLog(@"NEXT CARD");
	
	if (_cardIndex > 1) {
		SNArticleCardView_iPhone *cardView = (SNArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex];
		SNArticleCardView_iPhone *nextCardView = (SNArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex - 1];
		
		nextCardView.holderView.hidden = YES;
		nextCardView.scaledImgView.hidden = NO;
		nextCardView.frame = CGRectMake(0.0, 0.0, nextCardView.frame.size.width, nextCardView.frame.size.height);
		
		_isSwiping = YES;
		[UIView animateWithDuration:0.33 animations:^(void) {
			cardView.frame = CGRectMake(-self.view.frame.size.width, 0.0, cardView.frame.size.width, cardView.frame.size.height);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
				nextCardView.scaledImgView.frame = CGRectMake(0.0, 0.0, cardView.frame.size.width, cardView.frame.size.height);
			
			} completion:^(BOOL finished) {
				nextCardView.scaledImgView.hidden = YES;
				nextCardView.scaledImgView.frame = CGRectMake(((nextCardView.frame.size.width - (nextCardView.frame.size.width * kImageScale)) * 0.5), ((nextCardView.frame.size.height - (nextCardView.frame.size.height * kImageScale)) * 0.5), nextCardView.frame.size.width * kImageScale, nextCardView.frame.size.height * kImageScale);
				nextCardView.holderView.hidden = NO;
			}];
			
			_isSwiping = NO;
			_cardIndex--;
		}];
	}
}


#pragma mark - Notification handlers
-(void)_startVideo:(NSNotification *)notification {
	SNArticleVideoPlayerViewController_iPhone *articleListViewController = [[[SNArticleVideoPlayerViewController_iPhone alloc] init] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:articleListViewController] autorelease];
	
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController presentModalViewController:navigationController animated:YES];
}

-(void)_tagSearch:(NSNotification *)notification {
	[self _goBack];
}


//CGAffineTransform transform = scaleCardView.transform;
//scaleCardView.transform = CGAffineTransformScale(transform, 1.18f, 1.18f);

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
				[_cardViews addObject:articleCardView];
				
				/*
				 UIImageView *scaledImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(((articleCardView.frame.size.width - (articleCardView.frame.size.width * kImageScale)) * 0.5), ((articleCardView.frame.size.height - (articleCardView.frame.size.height * kImageScale)) * 0.5), articleCardView.frame.size.width * kImageScale, articleCardView.frame.size.height * kImageScale)] autorelease];
				scaledImgView.image = [UIImage imageWithCGImage:[[SNAppDelegate imageWithView:articleCardView] CGImage] scale:1.0 orientation:UIImageOrientationUp];
				[articleCardView setScaledImgView:scaledImgView];
				*/
				
				tot++;
			}
			
			_articles = [articleList retain];
			[articleList release];
			
			for (SNArticleCardView_iPhone *cardView in _cardViews) {
				[_cardHolderView addSubview:cardView];
			}
			
			SNArticleCardView_iPhone *articleCardView = (SNArticleCardView_iPhone *)[_cardViews objectAtIndex:[_cardViews count] - 1];
			[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
				articleCardView.scaledImgView.frame = CGRectMake(0.0, 0.0, articleCardView.frame.size.width, articleCardView.frame.size.height);
				
			} completion:^(BOOL finished) {
				articleCardView.scaledImgView.hidden = YES;
				articleCardView.scaledImgView.frame = CGRectMake(((articleCardView.frame.size.width - (articleCardView.frame.size.width * kImageScale)) * 0.5), ((articleCardView.frame.size.height - (articleCardView.frame.size.height * kImageScale)) * 0.5), articleCardView.frame.size.width * kImageScale, articleCardView.frame.size.height * kImageScale);
				articleCardView.holderView.hidden = NO;
			}];
			 
			_cardIndex = [_cardViews count] - 1;
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
