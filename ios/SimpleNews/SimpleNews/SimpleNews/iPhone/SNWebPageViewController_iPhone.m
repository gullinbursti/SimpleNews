//
//  SNWebPageViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNWebPageViewController_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
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
	_webView = nil;
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0)];
	[_webView setBackgroundColor:[UIColor clearColor]];
	_webView.delegate = self;
	[_webView loadRequest:[NSURLRequest requestWithURL:_url]];	
	[self.view addSubview:_webView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:_pageTitle];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	_progressHUD = nil;
	
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - WebView Delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return (YES);
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
	_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	[_progressHUD hide:YES];
	_progressHUD = nil;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {	
	NSLog(@"didFailLoadWithError:[%@]", error);
	[_progressHUD hide:YES];
	_progressHUD = nil;
	
	if ([error code] == NSURLErrorCancelled)
		return;
}

@end
