//
//  SNYouTubeScraper.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.09.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SNYouTubeRequestLoading = 0, 
	SNYouTubeDOMParsing
} SNYouTubeLoadState;

@protocol SNYouTubeScraperDelegate;
@interface SNYouTubeScraper : NSObject <UIWebViewDelegate> {
	id _delegate;
	NSString *_ytID;
	NSMutableArray *_youtubeIDs;
	BOOL _isQueued;
	int _cnt;
	
	BOOL _isDOMTested;
	NSUInteger _retryCount;
	NSInteger  _domWaitCounter;
	UIWebView *_webView;
}

@property (nonatomic, assign) id <SNYouTubeScraperDelegate> delegate;
@property (nonatomic, retain) NSString *ytID;

-(id)initWithYouTubeID:(NSString *)ytID;
-(id)initWithYouTubeIDs:(NSMutableArray *)ytIDs;
-(void)destroyMe;

@end

@protocol SNYouTubeScraperDelegate
-(void)snYouTubeScraperDidExtractMP4:(NSString *)url forYouTubeID:(NSString *)ytID;

@optional
-(void)snYouTubeScraperFinshedQueue;
@end
