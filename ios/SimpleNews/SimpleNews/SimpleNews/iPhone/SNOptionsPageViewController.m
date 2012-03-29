//
//  SNOptionsPageViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNOptionsPageViewController.h"

#import "SNAppDelegate.h"

@implementation SNOptionsPageViewController

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_url = url;
	}
	
	return (self);
}

-(void)dealloc {
	[_webView release];
	
	[super dealloc];
}

#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	_webView = [[UIWebView alloc] initWithFrame:self.view.frame];
	[_webView setBackgroundColor:[UIColor clearColor]];
	_webView.hidden = YES;
	_webView.delegate = self;
	[_webView loadRequest:[NSURLRequest requestWithURL:_url]];	
	[self.view addSubview:_webView];
	
	UIButton *backButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	backButton.frame = CGRectMake(250.0, 12.0, 64.0, 34.0);
	[backButton setBackgroundImage:[[UIImage imageNamed:@"doneButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[[UIImage imageNamed:@"doneButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	backButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	backButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	backButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	backButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[backButton setTitle:@"Done" forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
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
