//
//  SNArticleDetailsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "GANTracker.h"
#import "SNArticleDetailsViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNNavShareBtnView.h"
#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNWebPageViewController_iPhone.h"

#import "ImageFilter.h"

@implementation SNArticleDetailsViewController_iPhone

-(id)initWithArticleVO:(SNArticleVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
		_isOptions = NO;
		_isTextView = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeFontSize:) name:@"CHANGE_FONT_SIZE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_uiThemedDark:) name:@"UI_THEMED_DARK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_uiThemedLight:) name:@"UI_THEMED_LIGHT" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_detailsShowComments:) name:@"DETAILS_SHOW_COMMENTS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterShare:) name:@"TWITTER_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_emailShare:) name:@"EMAIL_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cancelShare:) name:@"CANCEL_SHARE" object:nil];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/lists/%d/%@/comments", _vo.list_id, _vo.title] withError:&error])
			NSLog(@"error in trackPageview");
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	_webView.delegate = nil;
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	_darkBGImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	_darkBGImgView.hidden = YES;
	_darkBGImgView.image = [UIImage imageNamed:@"background_stripes.png"];
	[self.view addSubview:_darkBGImgView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.title];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	SNNavShareBtnView *shareBtnView = [[SNNavShareBtnView alloc] initWithFrame:CGRectMake(276.0, 0.0, 44.0, 44.0)];
	[[shareBtnView btn] addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:shareBtnView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 49.0, self.view.frame.size.width, self.view.frame.size.height - 49.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	if ([SNAppDelegate isDarkStyleUI])
		[_scrollView setBackgroundColor:[UIColor blackColor]];
	
	else
		[_scrollView setBackgroundColor:[UIColor whiteColor]];
	
	[_scrollView setBackgroundColor:[UIColor clearColor]];
	
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_toggleLtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(78.0, 13.0, 164.0, 34.0)];
	_toggleLtImgView.image = [UIImage imageNamed:@"toggleBGLeft.png"];
	[_scrollView addSubview:_toggleLtImgView];
	
	UILabel *textOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 8.0, 100.0, 16.0)];
	textOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	textOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	textOnLabel.backgroundColor = [UIColor clearColor];
	textOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	textOnLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	textOnLabel.text = @"Text View";
	[_toggleLtImgView addSubview:textOnLabel];
	
	UILabel *webOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 8.0, 100.0, 16.0)];
	webOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	webOffLabel.textColor = [UIColor blackColor];
	webOffLabel.backgroundColor = [UIColor clearColor];
	webOffLabel.text = @"Web View";
	[_toggleLtImgView addSubview:webOffLabel];
	
	_toggleRtImgView = [[UIImageView alloc] initWithFrame:CGRectMake(78.0, 13.0, 164.0, 34.0)];
	_toggleRtImgView.image = [UIImage imageNamed:@"toggleBGRight.png"];
	_toggleRtImgView.hidden = YES;
	[_scrollView addSubview:_toggleRtImgView];
	
	UILabel *textOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 8.0, 100.0, 16.0)];
	textOffLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	textOffLabel.textColor = [UIColor blackColor];
	textOffLabel.backgroundColor = [UIColor clearColor];
	textOffLabel.text = @"Text View";
	[_toggleRtImgView addSubview:textOffLabel];
	
	UILabel *webOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 8.0, 100.0, 16.0)];
	webOnLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	webOnLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.0];
	webOnLabel.backgroundColor = [UIColor clearColor];
	webOnLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	webOnLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	webOnLabel.text = @"Web View";
	[_toggleRtImgView addSubview:webOnLabel];
	
	UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toggleButton.frame = _toggleLtImgView.frame;
	[toggleButton addTarget:self action:@selector(_goTextToggle) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:toggleButton];
		
	_viewOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_viewOptionsButton.frame = CGRectMake(264.0, 8.0, 44.0, 44.0);
	[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_nonActive.png"] forState:UIControlStateNormal];
	[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_Active.png"] forState:UIControlStateHighlighted];
	[_viewOptionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
	//[self.view addSubview:_viewOptionsButton];
	
	int offset = 70;
	EGOImageView *thumbImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(25.0, offset, 24.0, 24.0)];
	thumbImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
	thumbImgView.layer.cornerRadius = 4.0;
	thumbImgView.clipsToBounds = YES;
	[_scrollView addSubview:thumbImgView];
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = thumbImgView.frame;
	[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:avatarButton];
	offset += 4;
	
	NSString *timeSince = @"";
	int mins = [SNAppDelegate minutesAfterDate:_vo.added];
	int hours = [SNAppDelegate hoursAfterDate:_vo.added];
	int days = [SNAppDelegate daysAfterDate:_vo.added];
	
	if (days > 0) {
		timeSince = [NSString stringWithFormat:@"%dd from ", days];
		
	} else {
		if (hours > 0)
			timeSince = [NSString stringWithFormat:@"%dh from ", hours];
		
		else
			timeSince = [NSString stringWithFormat:@"%dm from ", mins];
	}
	
	CGSize size = [timeSince sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, offset, size.width, 16.0)];
	dateLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
	dateLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.text = timeSince;
	[_scrollView addSubview:dateLabel];
	
	CGSize size2 = [[NSString stringWithFormat:@"@%@ ", _vo.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *twitterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateLabel.frame.origin.x + size.width, offset, size2.width, 16.0)];
	twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	twitterNameLabel.textColor = [SNAppDelegate snLinkColor];
	twitterNameLabel.backgroundColor = [UIColor clearColor];
	twitterNameLabel.text = [NSString stringWithFormat:@"@%@", _vo.twitterHandle];
	[_scrollView addSubview:twitterNameLabel];
	
	UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	handleButton.frame = twitterNameLabel.frame;
	[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:handleButton];
	
	size = [@"via " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(twitterNameLabel.frame.origin.x + size2.width, offset, size.width, 16.0)];
	viaLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
	viaLabel.textColor = [UIColor colorWithWhite:0.525 alpha:1.0];
	viaLabel.backgroundColor = [UIColor clearColor];
	viaLabel.text = @"via ";
	[_scrollView addSubview:viaLabel];	
	
	size2 = [_vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(viaLabel.frame.origin.x + size.width, offset, size2.width, 16.0)];
	sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	sourceLabel.textColor = [SNAppDelegate snLinkColor];
	sourceLabel.backgroundColor = [UIColor clearColor];
	sourceLabel.text = _vo.articleSource;
	[_scrollView addSubview:sourceLabel];
	offset += 45;
	
	NSArray *fontSizes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"uiFontSizes"] objectAtIndex:[SNAppDelegate fontFactor]];
	
	size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:[[fontSizes objectAtIndex:0] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, offset, 274.0, size.height)];
	_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:[[fontSizes objectAtIndex:0] intValue]];
	
	if ([SNAppDelegate isDarkStyleUI])
		_titleLabel.textColor = [UIColor whiteColor];
	
	else
		_titleLabel.textColor = [UIColor blackColor];
	
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textAlignment = UITextAlignmentCenter;
	_titleLabel.text = _vo.title;
	_titleLabel.numberOfLines = 0;
	[_scrollView addSubview:_titleLabel];
	offset += size.height + 38;
	
	_btnBGView = [[UIView alloc] initWithFrame:CGRectMake(68.0, offset, 184.0, 35.0)];
	_btnBGView.layer.cornerRadius = 17.0;
	[_scrollView addSubview:_btnBGView];
	offset += 34;
	
	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentButton.frame = CGRectMake(5.0, 0.0, 94.0, 44.0);
	[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive.png"] forState:UIControlStateNormal];
	[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active.png"] forState:UIControlStateHighlighted];
	[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
	[commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
	commentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
	[commentButton setTitle:@"Comment" forState:UIControlStateNormal];
	[_btnBGView addSubview:commentButton];
	
	_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_likeButton.frame = CGRectMake(115.0, 0.0, 74.0, 44.0);
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
	_likeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
	[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
	[_btnBGView addSubview:_likeButton];
	
	if (_vo.hasLiked)
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
	
	else
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
	
	
	offset += 38;
	
	_articleImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(25.0, offset, 270.0, 270.0 * _vo.imgRatio)];
	_articleImgView.delegate = self;
	_articleImgView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
	[_scrollView addSubview:_articleImgView];
	offset += (270.0 * _vo.imgRatio);
	
//	if ([_vo.affiliateURL length] > 0) {
//		UIImageView *affiliateImgView = [[UIImageView alloc] initWithFrame:CGRectMake(25.0, offset, 34.0, 34.0)];
//		affiliateImgView.image = [UIImage imageNamed:@"favButton_nonActive.png"];
//		[_scrollView addSubview:affiliateImgView];
//		
//		size = [_vo.affiliateURL sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];	
//		UIButton *affiliateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		affiliateButton.frame = CGRectMake(62.0, offset, size.width, 34.0);
//		[affiliateButton addTarget:self action:@selector(_goAffiliate) forControlEvents:UIControlEventTouchUpInside];
//		affiliateButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
//		[affiliateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//		[affiliateButton setTitle:_vo.affiliateURL forState:UIControlStateNormal];
//		[_scrollView addSubview:affiliateButton];
//		
//		offset += 48;
//	}
	
	offset += 38;
	if (_vo.type_id > 4) {
		_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(25.0, offset, 270.0, 202.0) articleVO:_vo];
		//[_videoPlayerView startPlayback];
		[_scrollView addSubview:_videoPlayerView];		
		offset += _videoPlayerView.frame.size.height + 38;
	}
	
	//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	//	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	//	NSString *dateString = [dateFormatter stringFromDate:_vo.added];
	//	
	//	_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, offset, 100.0, 16.0)];
	//	_dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:2] intValue]];
	//	_dateLabel.textColor = [UIColor blackColor];
	//	_dateLabel.backgroundColor = [UIColor clearColor];
	//	_dateLabel.text = dateString;
	//	[_scrollView addSubview:_dateLabel];
	//	offset += 22 + 16;
	
	size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:3] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(25.0, offset, self.view.frame.size.width - 50.0, size.height + (90.0 + ([SNAppDelegate fontFactor] * 40.0)))];
	[_webView setBackgroundColor:[UIColor clearColor]];
	_webView.delegate = self;
	_webView.opaque = NO;
	_webView.scrollView.bounces = NO;
	_webView.scrollView.contentSize = _webView.frame.size;
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"article" ofType:@"html"]]]];
	[_scrollView addSubview:_webView];				
	
	offset += size.height + (90.0 + ([SNAppDelegate fontFactor] * 40.0));
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, offset);
	
	
	_sourceWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 70.0, self.view.frame.size.width, self.view.frame.size.height - 70.0)];
	_sourceWebView.scrollView.bounces = NO;
	_sourceWebView.hidden = YES;
	[_sourceWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_vo.article_url]]];
	[self.view addSubview:_sourceWebView];			
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.view.frame];
	[_blackMatteView setBackgroundColor:[UIColor blackColor]];
	_blackMatteView.alpha = 0.0;
	[self.view addSubview:_blackMatteView];
	
	_shareSheetView = [[SNShareSheetView_iPhone alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 339.0)];
	[_shareSheetView setVo:_vo];
	[self.view addSubview:_shareSheetView];
	
	UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goTwitterProfile {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", _vo.twitterHandle]] title:[NSString stringWithFormat:@"@%@", _vo.twitterHandle]];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goAffiliate {
	NSLog(@"AFFILIATE");
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_vo.affiliateURL]];
}

-(void)_goTextToggle {
	_isTextView = !_isTextView;
	
	_toggleLtImgView.hidden = !_isTextView;
	_toggleRtImgView.hidden = _isTextView;
	
	_sourceWebView.hidden = _isTextView;
}

-(void)_goShare {
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_blackMatteView.alpha = 0.67;
		_shareSheetView.frame = CGRectMake(0.0, self.view.frame.size.height - _shareSheetView.frame.size.height, _shareSheetView.frame.size.width, _shareSheetView.frame.size.height);
		
	} completion:^(BOOL finished) {
	}];
}

-(void)_goLike {
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateHighlighted];
	[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[likeRequest startAsynchronous];
	
	_vo.totalLikes++;
	[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
}

-(void)_goReadLater {
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	ASIFormDataRequest *readLaterRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readLaterRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[readLaterRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readLaterRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readLaterRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readLaterRequest startAsynchronous];
}


#pragma mark - Notification handlers
-(void)_changeFontSize:(NSNotification *)notification {
	
	CGSize size;
	int offset = 70;
	
	NSArray *fontSizes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"uiFontSizes"] objectAtIndex:[SNAppDelegate fontFactor]];
	
	offset += 45;
	size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:[[fontSizes objectAtIndex:0] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, offset, _titleLabel.frame.size.width, size.height);
	_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:[[fontSizes objectAtIndex:0] intValue]];
	offset += size.height + 38;
	
	_btnBGView.frame = CGRectMake(_btnBGView.frame.origin.x, offset, _btnBGView.frame.size.width, _btnBGView.frame.size.height);
	offset += 34;
	offset += 38;
	
	_articleImgView.frame = CGRectMake(_articleImgView.frame.origin.x, offset, _articleImgView.frame.size.width, _articleImgView.frame.size.height);
	offset += (270.0 * _vo.imgRatio);
	offset += 38;
	
	if (_vo.type_id > 4) {
		_videoPlayerView.frame = CGRectMake(_videoPlayerView.frame.origin.x, offset, _videoPlayerView.frame.size.width, _videoPlayerView.frame.size.height);
		offset += _videoPlayerView.frame.size.height + 22;
	}
	
	
	size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:3] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_webView.frame = CGRectMake(_webView.frame.origin.x, offset, _webView.frame.size.width, size.height + (90.0 + ([SNAppDelegate fontFactor] * 40.0)));
	offset += size.height + (90.0 + ([SNAppDelegate fontFactor] * 40.0));
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, offset);
	[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeFontFactor(%d);", [SNAppDelegate fontFactor]]];
}

-(void)_uiThemedDark:(NSNotification *)notification {
	_darkBGImgView.hidden = NO;
	_titleLabel.textColor = [UIColor whiteColor];
	_dateLabel.textColor = [UIColor whiteColor];
	
	[_webView stringByEvaluatingJavaScriptFromString:@"goDarkUI();"];
}

-(void)_uiThemedLight:(NSNotification *)notification {
	_darkBGImgView.hidden = YES;
	_titleLabel.textColor = [UIColor blackColor];
	_dateLabel.textColor = [UIColor blackColor];
	
	[_webView stringByEvaluatingJavaScriptFromString:@"goLightUI();"];
}

-(void)_detailsShowComments:(NSNotification *)notification {
	[self.navigationController pushViewController:[[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:_vo listID:_vo.list_id] animated:YES];
}

-(void)_twitterShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
	
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
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"Your phone is not currently configured to send mail." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
		
		[alert show];
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


#pragma mark - WebView delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *urlString = [[request URL] absoluteString];
	
	if ([urlString hasPrefix:@"result:"]) {
		NSArray *pathComponents = [[[request URL] path] pathComponents];
		
		NSString *key = [pathComponents objectAtIndex:1];
		NSString *value = [pathComponents objectAtIndex:2];
		
		NSLog(@"['%@'] = \"%@\"", key, value);
		
		if ([key isEqualToString:@"height"]) {
			webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, [value intValue]);
			//_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, [value intValue]);
			
		} else if ([key isEqualToString:@"time"]) {			
		} else if ([key isEqualToString:@"state"]) {
		}
		
		return (NO);
		
	} else
		return (YES);
}


-(void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webViewDidStartLoad");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"webViewDidFinishLoad");
	
	[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"populate('%@');", _vo.content]];
	[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeFontFactor(%d);", [SNAppDelegate fontFactor]]];
	
	if ([SNAppDelegate isDarkStyleUI])
		[self _uiThemedDark:nil];
	
	else
		[self _uiThemedLight:nil];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {	
	NSLog(@"didFailLoadWithError:[%@]", error);
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
}


#pragma mark - Image View delegates
-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	NSLog(@"LOADED [%@]", imageView.imageURL);
	UIImage *img = imageView.image;
	imageView.image = [img saturate:(1 + 1 - 0.5)];
}

@end
