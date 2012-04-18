//
//  SNWebPageViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNWebPageViewController_iPhone : UIViewController <UIWebViewDelegate> {
	NSString *_pageTitle;
	NSURL *_url;
	UIWebView *_webView;
}

-(id)initWithURL:(NSURL *)url title:(NSString *)title;

@end
