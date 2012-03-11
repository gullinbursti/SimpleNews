//
//  SNYouTubeScraper.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.09.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNYouTubeScraper.h"

@interface SNYouTubeScraper()
-(BOOL)_goAttemptScrape;
-(void)_goCleanup;
-(void)_onLoadedDOM;
-(void)_onFailedDOM:(NSError *)error;
@end

@implementation SNYouTubeScraper

#define kMaxNumberOfRetries 2 // numbers of retries
#define kWatchdogDelay 5.f    // seconds we wait for the DOM
#define kExtraDOMDelay 1.f    // if DOM doesn't load, wait for some extra time

@synthesize delegate = _delegate;
@synthesize ytID = _ytID;

-(id)initWithYouTubeID:(NSString *)ytID {
	if ((self = [super init])) {
		_ytID = ytID;
		_isQueued = NO;
		_cnt = -1;
		
		[self _goAttemptScrape];
	}
	
	return (self);
}

-(void)setYtID:(NSString *)ytID {
	_ytID = ytID;
	
	[self _goCleanup];
	[self _goAttemptScrape];
}

-(id)initWithYouTubeIDs:(NSMutableArray *)ytIDs {
	if ((self = [super init])) {
		_youtubeIDs = ytIDs;
		_cnt = 0;
		
		_ytID = [_youtubeIDs objectAtIndex:_cnt];
		NSLog(@"TOTAL:[%@]", _youtubeIDs);
		
		_isQueued = YES;
		[self _goAttemptScrape];
		
	}
	
	return (self);
}

-(void)destroyMe {
	[self _goCleanup];
}


-(void)dealloc {
	_delegate = nil;
	_ytID = nil;
	_webView = nil;
	[_youtubeIDs release];
	
	
	[super dealloc];
}


#pragma mark - Private methods
-(void)_onLoadedDOM {
	
	// figure out if we can extract the youtube url!
	NSString *youTubeMP4URL = [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video')[0].getAttribute('src')"];
	NSLog(@"testing dom. query: %@", youTubeMP4URL);
	
	if ([youTubeMP4URL hasPrefix:@"http"]) {
		//NSLog(@"Finished extracting: %@", youTubeMP4URL);
		
		NSRange range = [youTubeMP4URL rangeOfString:@"tag=36"];
		NSLog(@"RANGE OF 'TAG=36' (%d)", range.location);
		
		if (range.location < [youTubeMP4URL length]) {
			[self _goCleanup];
			[self _goAttemptScrape];
			
		} else {
			[_delegate snYouTubeScraperDidExtractMP4:youTubeMP4URL forYouTubeID:_ytID];
		}
		
		if (_isQueued) {
			_cnt++;
			
			if (_cnt == [_youtubeIDs count]) {
				_isQueued = NO;
				[_delegate snYouTubeScraperFinshedQueue];
				[self _goCleanup];
			
			} else {
				_ytID = [_youtubeIDs objectAtIndex:_cnt];
				[self _goAttemptScrape];
			}
		
		} else
			[self _goCleanup];
		
	} else {
		if (_domWaitCounter < kExtraDOMDelay * 4) {
			_domWaitCounter++;
			[self performSelector:@selector(_onLoadedDOM) withObject:nil afterDelay:0.25f]; // try often!
			
			return;
		}
		
		if (![self _goAttemptScrape]) {
			//NSError *error = [NSError errorWithDomain:@"com.sparklemountain.simplenews" code:100 userInfo:[NSDictionary dictionaryWithObject:@"MP4 URL could not be found." forKey:NSLocalizedDescriptionKey]];
			//if (failureBlock_) {
			//	failureBlock_(error);
			//}
			[self _goCleanup];
		}
	}
}

-(void)_onFailedDOM:(NSError *)error {
	if (![self _goAttemptScrape]) {
		NSLog(@"FAILED!!!");
		
		[self _goCleanup];
	}
}


-(BOOL)_goAttemptScrape {
	NSLog(@"_goAttemptScrape");
	
	if ((_retryCount <= kMaxNumberOfRetries + 1)) {
		_retryCount++;
		_domWaitCounter = 0;
		
		_webView.delegate = nil;
		_webView = [[UIWebView alloc] init];
		_webView.delegate = self;
		
		[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", _ytID]]]];
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		
		return (YES);
	}
	return (NO);
}

- (void)_goCleanup {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[_webView stopLoading];
	_webView.delegate = nil;
	_webView = nil;
	_retryCount = 0;
	_domWaitCounter = 0;
}




#pragma mark - WebView Delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	BOOL shouldLoad = YES;
	NSURL *url = [request URL];
	NSString *scheme = [url scheme];
	
	// check for DOM load message
	if ([scheme isEqualToString:@"x-sswebview"]) {
		NSString *host = [url host];
		
		if ([host isEqualToString:@"dom-loaded"]) {
			NSLog(@"DOM load detected!");
			dispatch_async(dispatch_get_main_queue(), ^{
				[self _onLoadedDOM];
			});
		}
		
		return (NO);
	}
	
	else
		shouldLoad = [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
	
	
	if (shouldLoad == NO)
		return (NO);
	
	_isDOMTested = NO;
	
	return (shouldLoad);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
	// check DOM
	if (_isDOMTested == NO) {
		_isDOMTested = YES;
		
		// the internal delegate will intercept this load and forward the event to the real delegate
		[_webView stringByEvaluatingJavaScriptFromString:@"var _SSWebViewDOMLoadTimer=setInterval(function(){if(/loaded|complete/.test(document.readyState)){clearInterval(_SSWebViewDOMLoadTimer);location.href='x-sswebview://dom-loaded'}},10);"];        
	}
	
	// add watchdog in case DOM never get initialized
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_onLoadedDOM) object:nil];
	[self performSelector:@selector(_onLoadedDOM) withObject:nil afterDelay:kWatchdogDelay];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {	
	NSLog(@"didFailLoadWithError");
	
	
	NSURL *errorURL = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
	if ([[errorURL absoluteString] rangeOfString:@"poswidget"].length) {
		NSLog(@"ignoring error: %@", error);
		return; // ignore those errors
	}
	
	NSLog(@"didFailLoadWithError: %@", error);
	
	// give system a little bit more time, may be an irrelevant error
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(_onFailedDOM:) withObject:error afterDelay:kWatchdogDelay / 3];
}


@end
