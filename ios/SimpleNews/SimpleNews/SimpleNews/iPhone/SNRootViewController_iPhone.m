//
//  SNRootViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "GANTracker.h"

#import "SNRootViewController_iPhone.h"
#import "SNListVO.h"
#import "SNTopicVO.h"

#import "SNProfileViewController_iPhone.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNRootTopicViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNArticleDetailsViewController_iPhone.h"
#import "SNArticleCommentsViewController_iPhone.h"

#import "MBProgressHUD.h"
#import "MBLResourceLoader.h"

@interface SNRootViewController_iPhone () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *topicsListResource;
@property(nonatomic, strong) MBLAsyncResource *fullscreenImgResource;
- (void)_refreshUserAccount;
- (void)_refreshTopicsList;
- (void)_hideFullscreenMedia:(NSNotification *)notification;
@end

@implementation SNRootViewController_iPhone

@synthesize topicsListResource = _topicsListResource;
@synthesize fullscreenImgResource = _fullscreenImgResource;


- (id)init {
	if ((self = [super init])) {
		_topicCells = [NSMutableArray new];
		_topicsList = [NSMutableArray new];
		
		_isIntro = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showShareSheet:) name:@"SHOW_SHARE_SHEET" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticlePage:) name:@"SHOW_ARTICLE_PAGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleComments:) name:@"SHOW_ARTICLE_COMMENTS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_timelineReturn:) name:@"TIMELINE_RETURN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFullscreenMedia:) name:@"SHOW_FULLSCREEN_MEDIA" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideFullscreenMedia:) name:@"HIDE_FULLSCREEN_MEDIA" object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	self.topicsListResource = nil;
	self.fullscreenImgResource = nil;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == [_topicTimelineView overlayView]) {
		CGPoint location = [touch locationInView:self.view];
		_touchPt = CGPointMake(_topicTimelineView.center.x - location.x, _topicTimelineView.center.y - location.y);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {	
	UITouch *touch = [touches anyObject];
	
	
	// If the touch was in the placardView, move the placardView to its location
	if ([touch view] == [_topicTimelineView overlayView]) {
		CGPoint touchLocation = [touch locationInView:self.view];
		CGPoint location = CGPointMake(MIN(MAX(_touchPt.x + touchLocation.x, 160.0), 386.0), _topicTimelineView.center.y);
		
		_topicTimelineView.center = location;
		
		//NSLog(@"TOUCHED:[%f, %f]", _topicTimelineView.center.x, _topicTimelineView.center.y);
		return;
	}
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	
	if (CGRectContainsPoint(_videoPlayerView.frame, touchPoint))
		[_videoPlayerView toggleControls];//NSLog(@"TOUCHED:(%f, %f)", touchPoint.x, touchPoint.y);
	
	if (CGRectContainsPoint(_fullscreenImgView.frame, touchPoint))
		[self _hideFullscreenMedia:nil];
	
	NSLog(@"TOUCHED:[%f, %f] (%d)", touchPoint.x, touchPoint.y, _isTimeline);
	
	//if (!_isTimeline) {
		if (touchPoint.x < 140.0 && !CGPointEqualToPoint(_touchPt, touchPoint) && !_isTimeline) {
			[UIView animateWithDuration:0.25 animations:^(void) {
				_topicTimelineView.frame = CGRectMake(0.0, 0.0, _topicTimelineView.frame.size.width, _topicTimelineView.frame.size.height);
			
			} completion:^(BOOL finished) {
				_isTimeline = YES;
				[_topicTimelineView fullscreenMediaEnabled:_isTimeline];
				
			}];
			
		} 
		
		if (touchPoint.x > 140.0 && !CGPointEqualToPoint(_touchPt, touchPoint)) {
			[UIView animateWithDuration:0.25 animations:^(void) {
				_topicTimelineView.frame = CGRectMake(kTopicOffset, 0.0, _topicTimelineView.frame.size.width, _topicTimelineView.frame.size.height);
			
			} completion:^(BOOL finished) {
				_isTimeline = NO;
				[_topicTimelineView fullscreenMediaEnabled:_isTimeline];
				
			}];
		}
	//}
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	//_holderView = [[UIView alloc] initWithFrame:CGRectMake(-270.0, 0.0, 580.0, self.view.frame.size.height)];
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_holderView];
	
	_profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_profileButton.frame = CGRectMake(10.0, 8.0, 44.0, 44.0);
	[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive.png"] forState:UIControlStateNormal];
	[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileButton_Active.png"] forState:UIControlStateHighlighted];
	[_profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[_holderView addSubview:_profileButton];
	
	_topicsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 56.0, kTopicOffset, self.view.frame.size.height - 56.0) style:UITableViewStylePlain];
	[_topicsTableView setBackgroundColor:[UIColor clearColor]];
	_topicsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_topicsTableView.rowHeight = 50.0;
	_topicsTableView.delegate = self;
	_topicsTableView.dataSource = self;
	_topicsTableView.scrollsToTop = NO;
	_topicsTableView.showsVerticalScrollIndicator = NO;
	[_holderView addSubview:_topicsTableView];
	
	_cardListsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cardListsButton.frame = CGRectMake(kTopicOffset, 45.0, 44.0, self.view.frame.size.height - 45.0);
	[_cardListsButton addTarget:self action:@selector(_goCardLists) forControlEvents:UIControlEventTouchUpInside];
	//[self.view addSubview:_cardListsButton];
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.view.frame];
	[_blackMatteView setBackgroundColor:[UIColor blackColor]];
	_blackMatteView.alpha = 0.0;
	[self.view addSubview:_blackMatteView];
	
	
	_fullscreenTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 6.0, 256.0, 28.0)];
	_fullscreenTitleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	_fullscreenTitleLabel.textColor = [UIColor whiteColor];
	_fullscreenTitleLabel.backgroundColor = [UIColor clearColor];
	[_blackMatteView addSubview:_fullscreenTitleLabel];
	
	UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 12.0, 256.0, 28.0)];
	infoLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	infoLabel.textColor = [UIColor blackColor];
	infoLabel.backgroundColor = [UIColor clearColor];
	[_blackMatteView addSubview:infoLabel];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	_holderView = nil;
	_profileButton = nil;
	_topicsTableView = nil;
	_cardListsButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_shadowImgView.alpha = 1.0;
	}];
	
	// Refresh any network resources that need loading
	[self _refreshTopicsList];
	[self _refreshUserAccount];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_isIntro) {
		[UIView animateWithDuration:0.33 delay:1.33 options:UIViewAnimationCurveEaseIn animations:^(void) {
			_cardListsButton.hidden = YES;
			_topicTimelineView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
			
		} completion:^(BOOL finished) {
			_isIntro = NO;
			_isTimeline = YES;
			[_topicTimelineView fullscreenMediaEnabled:_isTimeline];
		}];
	}
}

#pragma mark - Navigation

- (void)_goCardLists {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_cardListsButton.hidden = YES;
		_topicTimelineView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		//[UIView animateWithDuration:0.33 animations:^(void) {
		_topicsTableView.contentOffset = CGPointZero;
		_isTimeline = YES;
		[_topicTimelineView fullscreenMediaEnabled:_isTimeline];
	}];
}

-(void)_goProfile {
	
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	
	} else {
		[UIView animateWithDuration:0.33
						 animations:^(void) {
							 _shadowImgView.alpha = 0.0;
			
						 }
						 completion:^(BOOL finished) {
							 SNProfileViewController_iPhone *profileViewController = [[SNProfileViewController_iPhone alloc] init];
							 [self.navigationController pushViewController:profileViewController animated:YES];
						 }];
	}
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHEET" object:_articleVO];
}

-(void)_startVideo {
	[_videoPlayerView startPlayback];
}

#pragma mark - Network Requests
- (void)setFullscreenImgResource:(MBLAsyncResource *)fullscreenImgResource 
{
	if (_fullscreenImgResource != nil) {
		[_fullscreenImgResource unsubscribe:self];
		_fullscreenImgResource = nil;
	}
	
	_fullscreenImgResource = fullscreenImgResource;
	
	if (_fullscreenImgResource != nil)
		[_fullscreenImgResource subscribe:self];
}

- (void)setTopicsListResource:(MBLAsyncResource *)topicsListResource
{
	if (_topicsListResource != nil) {
		[_topicsListResource unsubscribe:self];
		_topicsListResource = nil;
	}
	
	_topicsListResource = topicsListResource;
	
	if (_topicsListResource != nil)
		[_topicsListResource subscribe:self];
}

- (void)_refreshTopicsList
{
	if (_topicsListResource == nil) {
		_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_hud.labelText = NSLocalizedString(@"Loading Topics…", @"Status message when loading topics list");
		_hud.mode = MBProgressHUDModeIndeterminate;
		_hud.graceTime = 2.0;
		_hud.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Topics.php"];
		self.topicsListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration for now
	}
}

- (void)_refreshUserAccount
{
	if ((_userResource == nil) && ([SNAppDelegate twitterHandle] != nil)) {
		NSMutableDictionary *userFormValues = [NSMutableDictionary dictionary];
		[userFormValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[userFormValues setObject:[SNAppDelegate deviceToken] forKey:@"token"];
		[userFormValues setObject:[SNAppDelegate twitterHandle] forKey:@"handle"];
		[userFormValues setObject:[SNAppDelegate twitterID] forKey:@"twitterID"]; 
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"];
		_userResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:userFormValues forceFetch:YES expiration:[NSDate date]];
		[_userResource subscribe:self];
	}
}


#pragma mark - AsyncResource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data
{
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	if (resource == _userResource) {
		_hud.taskInProgress = NO;
		
		NSError *error = nil;
		NSDictionary *parsedUser = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error != nil) {
			NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			_hud.graceTime = 0.0;
			_hud.mode = MBProgressHUDModeCustomView;
			_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_hud.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_hud show:NO];
			[_hud hide:YES afterDelay:1.5];
			_hud = nil;
		}
		else {
			//_twitterRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@", [SNAppDelegate twitterHandle]]]];
			//[_twitterRequest setDelegate:self];
			//[_twitterRequest startAsynchronous];
			
			[SNAppDelegate writeUserProfile:parsedUser];
			
			[_hud hide:YES];
			_hud = nil;
		}
	}
	
	else if (resource == _topicsListResource) {
		_hud.taskInProgress = NO;
		
		NSError *error = nil;
		//NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		//NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
			_hud.graceTime = 0.0;
			_hud.mode = MBProgressHUDModeCustomView;
			_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_hud.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_hud show:NO];
			[_hud hide:YES afterDelay:1.5];
			_hud = nil;
		}
		else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNTopicVO *vo = [SNTopicVO topicWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
			}
			
			[_hud hide:YES];
			_hud = nil;
			
			_topicsList = list;
			[_topicsTableView reloadData];
			
			_topicTimelineView = [[SNTopicTimelineView_iPhone alloc] initWithPopularArticles];
			[_holderView addSubview:_topicTimelineView];
		}
	
	} else if (resource == _fullscreenImgResource) {
		_fullscreenImgView.image = [UIImage imageWithData:data];
		//_fullscreenImgView.image = [SNAppDelegate imageWithFilters:[UIImage imageWithData:data] filter:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"sharpen", @"type", [NSNumber numberWithFloat:1.0], @"amount", nil], nil]];
		
		_blackMatteView.hidden = NO;
		[UIView animateWithDuration:0.33 animations:^(void) {
			_blackMatteView.alpha = 0.95;
			_fullscreenImgView.frame = CGRectMake(0.0, (self.view.frame.size.height - (320.0 * _articleVO.imgRatio)) * 0.5, 320.0, 320.0 * _articleVO.imgRatio);
			
		} completion:^(BOOL finished) {
			UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_hideFullscreenMedia:)];
			tapRecognizer.numberOfTapsRequired = 1;
			[_blackMatteView addGestureRecognizer:tapRecognizer];
			
			_shareBtnView = [[SNNavShareBtnView alloc] initWithFrame:CGRectMake(272.0, 0.0, 44.0, 44.0)];
			[[_shareBtnView btn] addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:_shareBtnView];
		}];
	}
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error
{
	if (_hud != nil) {
		_hud.graceTime = 0.0;
		_hud.mode = MBProgressHUDModeCustomView;
		_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
		_hud.labelText = NSLocalizedString(@"Error", @"Error");
		[_hud show:NO];
		[_hud hide:YES afterDelay:1.5];
		_hud = nil;
	}
	
	// Show an error overlay?
	
	if (resource == _userResource)
		_userResource = nil;
}

#pragma mark - Notification handlers

-(void)_showArticleComments:(NSNotification *)notification {
	SNArticleCommentsViewController_iPhone *articleCommentsViewController = [[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:(SNArticleVO *)[notification object]];
	[self.navigationController pushViewController:articleCommentsViewController animated:YES];
}

-(void)_showArticlePage:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:vo.article_url] title:vo.title];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showShareSheet:(NSNotification *)notification {
	_articleVO = (SNArticleVO *)[notification object];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																				delegate:self 
																	cancelButtonTitle:@"Cancel" 
																 destructiveButtonTitle:nil 
																	otherButtonTitles:@"Twitter", @"SMS", @"Copy URL", @"Email", @"Open Web View", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.view];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}


-(void)_timelineReturn:(NSNotification *)notification {
	_isTimeline = NO;
	[_topicTimelineView fullscreenMediaEnabled:_isTimeline];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_topicTimelineView.frame = CGRectMake(kTopicOffset, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_cardListsButton.hidden = NO;
	}];
}

-(void)_twitterShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
	
	//[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
	[twitter addURL:[NSURL URLWithString:[NSString stringWithString:[NSString stringWithFormat:@"http://assemb.ly/tweets?id=%@", vo.tweetID]]]];
	[twitter setInitialText:[NSString stringWithFormat:@"via Assembly - %@", vo.title]];
	
	[self presentModalViewController:twitter animated:YES];
	
	twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
		
		ASIFormDataRequest *shareRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[shareRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[shareRequest setPostValue:[NSString stringWithFormat:@"%d", _articleVO.article_id] forKey:@"articleID"];
		[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"typeID"];
		[shareRequest setDelegate:self];
		[shareRequest startAsynchronous];
				
		[self dismissModalViewControllerAnimated:YES];
	};
}

-(void)_showFullscreenMedia:(NSNotification *)notification {
	NSLog(@"\n--SHOW FULLSCREEN MEDIA--");
	NSMutableDictionary *dict = [notification object];
	
	_articleVO = [dict objectForKey:@"VO"];
	float offset = [[dict objectForKey:@"offset"] floatValue];
	CGRect frame = [[dict objectForKey:@"frame"] CGRectValue];
	NSString *type = [dict objectForKey:@"type"];
	
	frame.origin.y = 44.0 + frame.origin.y + offset;
	_fullscreenFrame = frame;
	
	for (UIView *view in [_blackMatteView subviews])
		[view removeFromSuperview];
	
	_fullscreenTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 6.0, 256.0, 28.0)];
	_fullscreenTitleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	_fullscreenTitleLabel.textColor = [UIColor whiteColor];
	_fullscreenTitleLabel.backgroundColor = [UIColor clearColor];
	_fullscreenTitleLabel.text = _articleVO.title;
	[_blackMatteView addSubview:_fullscreenTitleLabel];
	
	CGSize size = [@"via " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 30.0, size.width, size.height)];
	viaLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10];
	viaLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
	viaLabel.backgroundColor = [UIColor clearColor];
	viaLabel.text = @"via ";
	[_blackMatteView addSubview:viaLabel];
	
	CGSize size2 = [[NSString stringWithFormat:@"@%@ ", _articleVO.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0 + size.width, 30.0, size2.width, size2.height)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
	handleLabel.textColor = [UIColor whiteColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@ ", _articleVO.twitterHandle];
	[_blackMatteView addSubview:handleLabel];
	 
	size = [@"into " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:10] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *inLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x + size2.width, 30.0, size.width, size.height)];
	inLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:10];
	inLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
	inLabel.backgroundColor = [UIColor clearColor];
	inLabel.text = @"into ";
	[_blackMatteView addSubview:inLabel];
	 
	size2 = [[NSString stringWithFormat:@"%@", _articleVO.topicTitle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(inLabel.frame.origin.x + size.width, 30.0, size2.width, size2.height)];
	topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
	topicLabel.textColor = [UIColor whiteColor];
	topicLabel.backgroundColor = [UIColor clearColor];
	topicLabel.text = [NSString stringWithFormat:@"%@", _articleVO.topicTitle];
	[_blackMatteView addSubview:topicLabel];
	
	
	if ([type isEqualToString:@"photo"]) {
		_fullscreenImgView = [[UIImageView alloc] initWithFrame:frame];
		_fullscreenImgView.userInteractionEnabled = YES;
		[self.view addSubview:_fullscreenImgView];
		
		_fullscreenImgResource = nil;
		self.fullscreenImgResource = [[MBLResourceLoader sharedInstance] downloadURL:_articleVO.imageURL forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration for now
		
	} else if ([type isEqualToString:@"video"]) {
		_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:frame articleVO:_articleVO];
		[self.view addSubview:_videoPlayerView];
		[self performSelector:@selector(_startVideo) withObject:nil afterDelay:1.0];
	
		_blackMatteView.hidden = NO;
		[UIView animateWithDuration:0.33 animations:^(void) {
			_blackMatteView.alpha = 0.95;
			[_videoPlayerView reframe:CGRectMake(0.0, (self.view.frame.size.height - 240.0) * 0.5, 320.0, 240.0)];
			
		} completion:^(BOOL finished) {
			UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_hideFullscreenMedia:)];
			tapRecognizer.numberOfTapsRequired = 1;
			[_blackMatteView addGestureRecognizer:tapRecognizer];
			
			_shareBtnView = [[SNNavShareBtnView alloc] initWithFrame:CGRectMake(272.0, 0.0, 44.0, 44.0)];
			[[_shareBtnView btn] addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:_shareBtnView];
			[self.view addSubview:_shareBtnView];
		}];
	}
}

-(void)_hideFullscreenMedia:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
		
		_fullscreenImgView.frame = _fullscreenFrame;
		[_videoPlayerView reframe:_fullscreenFrame];
		[_videoPlayerView stopPlayback];
		
		[_shareBtnView removeFromSuperview];
		_shareBtnView = nil;
		
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
		[_fullscreenImgView removeFromSuperview];
		[_videoPlayerView removeFromSuperview];
		[_shareBtnView removeFromSuperview];
		
		_fullscreenImgView = nil;
		_videoPlayerView = nil;
		_shareBtnView = nil;
	}];
	
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		if (![SNAppDelegate twitterHandle]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			
		} else {
			TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
			
			[twitter addURL:[NSURL URLWithString:_articleVO.article_url]];
			[twitter setInitialText:[NSString stringWithFormat:@"Check out… %@ via @getassembly %@", _articleVO.title, _articleVO.article_url]];
			[self presentModalViewController:twitter animated:YES];
			
			twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
				[self dismissModalViewControllerAnimated:YES];
				
				ASIFormDataRequest *shareRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
				[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
				[shareRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
				[shareRequest setPostValue:[NSString stringWithFormat:@"%d", _articleVO.article_id] forKey:@"articleID"];
				[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"typeID"];
				[shareRequest setDelegate:self];
				[shareRequest startAsynchronous];
			};
		}
		
	} else if (buttonIndex == 1) {
		MFMessageComposeViewController *mfViewController = [[MFMessageComposeViewController alloc] init];
		if([MFMessageComposeViewController canSendText]) {
			mfViewController.body = [NSString stringWithFormat:@"Check out… %@ via @getassembly %@", _articleVO.title, _articleVO.article_url];
			mfViewController.recipients = [NSArray arrayWithObjects:nil];
			mfViewController.messageComposeDelegate = self;
			[self presentViewController:mfViewController animated:YES completion:nil];
		}
		
		
	} else if (buttonIndex == 2) {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[pasteboard setValue:_articleVO.article_url forPasteboardType:@"public.utf8-plain-text"];
		//pasteboard.string = _vo.article_url;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pasteboard" 
																		message:@"URL copied to clipboard" 
																	  delegate:self 
														  cancelButtonTitle:@"OK" 
														  otherButtonTitles:nil];
		[alert show];
		
	} else if (buttonIndex == 3) {
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
			mfViewController.mailComposeDelegate = self;
			[mfViewController setSubject:[NSString stringWithFormat:@"Check out… %@ via @getassembly %@", _articleVO.title, _articleVO.article_url]];
			[mfViewController setMessageBody:[NSString stringWithFormat:@"Check out… %@ via @getassembly %@", _articleVO.title, _articleVO.article_url] isHTML:NO];
			
			[self presentViewController:mfViewController animated:YES completion:nil];
			
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" 
																			message:@"Your phone is not currently configured to send mail." 
																		  delegate:nil 
															  cancelButtonTitle:@"ok" 
															  otherButtonTitles:nil];
			[alert show];
		}
	
	} else if (buttonIndex == 4) {
		SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:_articleVO.article_url] title:_articleVO.title];
		[self.navigationController pushViewController:webPageViewController animated:YES];
	}
}



#pragma mark - TableView DataSource Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_topicsList count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNRootTopicViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNRootTopicViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNRootTopicViewCell_iPhone alloc] init];
		
	cell.topicVO = (SNTopicVO *)[_topicsList objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[_topicCells addObject:cell];
	return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (50.0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_topicTimelineView removeFromSuperview];
	_topicTimelineView = nil;
	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		((SNRootTopicViewCell_iPhone *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		((SNRootTopicViewCell_iPhone *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
	}];
	
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_shadowImgView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		if (indexPath.row == 0)
			_topicTimelineView = [[SNTopicTimelineView_iPhone alloc] initWithPopularArticles];	
		
		else
			_topicTimelineView = [[SNTopicTimelineView_iPhone alloc] initWithTopicVO:(SNTopicVO *)[_topicsList objectAtIndex:indexPath.row]];
		
		[_holderView addSubview:_topicTimelineView];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_cardListsButton.hidden = YES;
			_topicTimelineView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
			
		} completion:^(BOOL finished) {
			_topicsTableView.contentOffset = CGPointZero;
			_isTimeline = YES;
			[_topicTimelineView fullscreenMediaEnabled:_isTimeline];
		}];
	}];
}


#pragma mark - MailComposeViewController Delegates
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	ASIFormDataRequest *shareRequest;
	
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
			
		case MFMailComposeResultSaved:
			//[alert show];
			break;
			
		case MFMailComposeResultSent:			
			shareRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
			[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
			[shareRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
			[shareRequest setPostValue:[NSString stringWithFormat:@"%d", _articleVO.article_id] forKey:@"articleID"];
			[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"typeID"];
			[shareRequest setDelegate:self];
			[shareRequest startAsynchronous];
			break;
			
		case MFMailComposeResultFailed:
			break;
			
		default:
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MessageCompose Deleagtes
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	//NSLog(@"didFinishWithResult:[%@]", result);
	
	if (result == MessageComposeResultCancelled) {
		//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Assembly" message:@"Message Cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		//[alertView show];
	
	} else if (result == MessageComposeResultFailed) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Assembly" message:@"Send Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		
	} else if (result == MessageComposeResultSent) {
		//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Assembly" message:@"Message Sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		//[alertView show];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNProfileArticlesViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *sharedResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSLog(@"RESULT:%@", [sharedResult objectForKey:@"result"]);
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end