//
//  SNWebPageViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNWebPageViewController_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNWebPageViewController_iPhone

- (id)initWithURL:(NSURL *)url title:(NSString *)title {
	if ((self = [super init])) {
		_url = url;
		_pageTitle = title;
	}
	
	return (self);
}

-(void)dealloc {
}

#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_pageTitle];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(4.0, 4.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 53.0, self.view.frame.size.width, self.view.frame.size.height - 53.0)];
	[_webView setBackgroundColor:[UIColor clearColor]];
	_webView.hidden = YES;
	_webView.delegate = self;
	[_webView loadRequest:[NSURLRequest requestWithURL:_url]];	
	[self.view addSubview:_webView];
	
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


#pragma mark - WebView Delegates
-(void)webViewDidFinishLoad:(UIWebView *)webView {
	_webView.hidden = NO;
}

@end
