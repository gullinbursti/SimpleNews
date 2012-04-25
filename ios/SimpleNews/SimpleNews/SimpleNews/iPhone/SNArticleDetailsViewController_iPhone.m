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
#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleDetailsFooterView_iPhone.h"
#import "SNArticleVideoPlayerView_iPhone.h"

@implementation SNArticleDetailsViewController_iPhone

-(id)initWithArticleVO:(SNArticleVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
		_isOptions = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeFontSize:) name:@"CHANGE_FONT_SIZE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_uiThemedDark:) name:@"UI_THEMED_DARK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_uiThemedLight:) name:@"UI_THEMED_LIGHT" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_detailsShowComments:) name:@"DETAILS_SHOW_COMMENTS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_detailsShowShare:) name:@"DETAILS_SHOW_SHARE" object:nil];
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
	[super dealloc];
	[_webView dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 53.0, self.view.frame.size.width, self.view.frame.size.height - 53.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	if ([SNAppDelegate isDarkStyleUI])
		[_scrollView setBackgroundColor:[UIColor blackColor]];
	
	else
		[_scrollView setBackgroundColor:[UIColor whiteColor]];
	
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_articleOptionsView = [[SNArticleOptionsView_iPhone alloc] init];
	[self.view addSubview:_articleOptionsView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_vo.title];
	[self.view addSubview:headerView];
	
	SNArticleDetailsFooterView_iPhone *footerView = [[SNArticleDetailsFooterView_iPhone alloc] init];
	[self.view addSubview:footerView];
	
	UIButton *backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	backButton.frame = CGRectMake(4.0, 4.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	_viewOptionsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_viewOptionsButton.frame = CGRectMake(262.0, -6.0, 64.0, 64.0);
	[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_nonActive.png"] forState:UIControlStateNormal];
	[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_Active.png"] forState:UIControlStateHighlighted];
	[_viewOptionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_viewOptionsButton];
	
	CGSize size;
	int offset = 22;
	NSArray *fontSizes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"uiFontSizes"] objectAtIndex:[SNAppDelegate fontFactor]];
	
	size = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:[[fontSizes objectAtIndex:0] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, offset, 274.0, size.height)];
	_titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:[[fontSizes objectAtIndex:0] intValue]];
	
	if ([SNAppDelegate isDarkStyleUI])
		_titleLabel.textColor = [UIColor whiteColor];
	
	else
		_titleLabel.textColor = [UIColor blackColor];
	
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.text = _vo.title;
	_titleLabel.numberOfLines = 0;
	[_scrollView addSubview:_titleLabel];
	offset += size.height + 22;
	
	size = [_vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:1] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, offset, 274.0, size.height)];
	_sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:1] intValue]];
	
	if ([SNAppDelegate isDarkStyleUI])
		_sourceLabel.textColor = [UIColor whiteColor];
	
	else
		_sourceLabel.textColor = [UIColor blackColor];
	
	_sourceLabel.backgroundColor = [UIColor clearColor];
	_sourceLabel.text = _vo.articleSource;
	[_scrollView addSubview:_sourceLabel];
	offset += size.height + 22;
	
	EGOImageView *articleImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(22.0, offset, 274.0, 274.0 * _vo.imgRatio)];
	articleImgView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
	[_scrollView addSubview:articleImgView];
	offset += (274.0 * _vo.imgRatio);
	
	if ([_vo.affiliateURL length] > 0) {
		UIImageView *affiliateImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(22.0, offset, 34.0, 34.0)] autorelease];
		affiliateImgView.image = [UIImage imageNamed:@"favButton_nonActive.png"];
		[_scrollView addSubview:affiliateImgView];
		
		size = [_vo.affiliateURL sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];	
		UIButton *affiliateButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		affiliateButton.frame = CGRectMake(62.0, offset, size.width, 34.0);
		[affiliateButton addTarget:self action:@selector(_goAffiliate) forControlEvents:UIControlEventTouchUpInside];
		affiliateButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[affiliateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[affiliateButton setTitle:_vo.affiliateURL forState:UIControlStateNormal];
		[_scrollView addSubview:affiliateButton];
		
		offset += 48;
	}
	
	
	
	if (_vo.type_id > 4) {
		_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(22.0, offset, 274.0, 180.0) articleVO:_vo];
		//[_videoPlayerView startPlayback];
		[_scrollView addSubview:_videoPlayerView];		
		offset += _videoPlayerView.frame.size.height + 22;
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *dateString = [dateFormatter stringFromDate:_vo.added];
	[dateFormatter release];
	
	_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, offset, 100.0, 16.0)];
	_dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:2] intValue]];
	_dateLabel.textColor = [UIColor blackColor];
	_dateLabel.backgroundColor = [UIColor clearColor];
	_dateLabel.text = dateString;
	[_scrollView addSubview:_dateLabel];
	offset += 22 + 16;
	
	size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:3] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(22.0, offset, self.view.frame.size.width - 44.0, size.height + (90.0 + ([SNAppDelegate fontFactor] * 40.0)))];
	_webView.delegate = self;
	_webView.scrollView.bounces = NO;
	//_webView.scrollView.userInteractionEnabled = NO;
	_webView.scrollView.contentSize = _webView.frame.size;
	[_webView setBackgroundColor:[UIColor whiteColor]];
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"article" ofType:@"html"]]]];
	[_scrollView addSubview:_webView];				
	
	offset += size.height + (90.0 + ([SNAppDelegate fontFactor] * 40.0));
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, offset);
	
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.view.frame];
	[_blackMatteView setBackgroundColor:[UIColor blackColor]];
	_blackMatteView.alpha = 0.0;
	[self.view addSubview:_blackMatteView];
	
	_shareSheetView = [[SNShareSheetView_iPhone alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 339.0)];
	[self.view addSubview:_shareSheetView];
	
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


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goAffiliate {
	NSLog(@"AFFILIATE");
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_vo.affiliateURL]];
}

-(void)_goOptions {
	_isOptions = !_isOptions;
	
	if (_isOptions) {
		[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_Selected.png"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_articleOptionsView.frame = CGRectMake(_articleOptionsView.frame.origin.x, 53.0, _articleOptionsView.frame.size.width, _articleOptionsView.frame.size.height);
			_scrollView.contentOffset = CGPointMake(0.0, -_articleOptionsView.frame.size.height);
			//_scrollView.frame = CGRectMake(0.0, _scrollView.frame.origin.y + _articleOptionsView.frame.size.height, _scrollView.frame.size.width, _scrollView.frame.size.height);
		}];
		
	} else {
		[_viewOptionsButton setBackgroundImage:[UIImage imageNamed:@"fontButton_nonActive.png"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_articleOptionsView.frame = CGRectMake(_articleOptionsView.frame.origin.x, -26.0, _articleOptionsView.frame.size.width, _articleOptionsView.frame.size.height);
			_scrollView.contentOffset = CGPointZero;
			//_scrollView.frame = CGRectMake(0.0, _scrollView.frame.origin.y - _articleOptionsView.frame.size.height, _scrollView.frame.size.width, _scrollView.frame.size.height);
		}];
	}
}


#pragma mark - Notification handlers
-(void)_changeFontSize:(NSNotification *)notification {
	
	CGSize size;
	int offset = 22;
	
	NSArray *fontSizes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"uiFontSizes"] objectAtIndex:[SNAppDelegate fontFactor]];
	
	size = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:[[fontSizes objectAtIndex:0] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.y, offset, _titleLabel.frame.size.width, size.height);
	_titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:[[fontSizes objectAtIndex:0] intValue]];
	offset += size.height + 22;
	
	size = [_vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:1] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_sourceLabel.frame = CGRectMake(_sourceLabel.frame.origin.x, offset, _sourceLabel.frame.size.width, size.height);
	_sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:1] intValue]];
	offset += size.height + 22;
	
	if (_vo.type_id > 4) {
		_videoPlayerView.frame = CGRectMake(_videoPlayerView.frame.origin.x, offset, _videoPlayerView.frame.size.width, _videoPlayerView.frame.size.height);
		offset += _videoPlayerView.frame.size.height + 22;
	}
	
	_dateLabel.frame = CGRectMake(_dateLabel.frame.origin.x, offset, _dateLabel.frame.size.width, size.height);
	_dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:2] intValue]];
	offset += 22 + 16;
	
	size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:[[fontSizes objectAtIndex:3] intValue]] constrainedToSize:CGSizeMake(274.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	_webView.frame = CGRectMake(_webView.frame.origin.x, offset, _webView.frame.size.width, size.height + (90.0 + ([SNAppDelegate fontFactor] * 40.0)));
	offset += size.height + (90.0 + ([SNAppDelegate fontFactor] * 40.0));
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, offset);
	[_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeFontFactor(%d);", [SNAppDelegate fontFactor]]];
}

-(void)_uiThemedDark:(NSNotification *)notification {
	[_scrollView setBackgroundColor:[UIColor blackColor]];
	_titleLabel.textColor = [UIColor whiteColor];
	_sourceLabel.textColor = [UIColor whiteColor];
	_dateLabel.textColor = [UIColor whiteColor];
	
	[_webView stringByEvaluatingJavaScriptFromString:@"goDarkUI();"];
}

-(void)_uiThemedLight:(NSNotification *)notification {
	[_scrollView setBackgroundColor:[UIColor whiteColor]];
	_titleLabel.textColor = [UIColor blackColor];
	_sourceLabel.textColor = [UIColor blackColor];
	_dateLabel.textColor = [UIColor blackColor];
	
	[_webView stringByEvaluatingJavaScriptFromString:@"goLightUI();"];
}

-(void)_detailsShowComments:(NSNotification *)notification {
	[self.navigationController pushViewController:[[[SNArticleCommentsViewController_iPhone alloc] initWithArticleVO:_vo listID:_vo.list_id] autorelease] animated:YES];
}

-(void)_detailsShowShare:(NSNotification *)notification {
	[_shareSheetView setVo:_vo];
	
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

@end
