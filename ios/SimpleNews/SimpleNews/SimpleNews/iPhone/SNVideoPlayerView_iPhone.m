//
//  SNVideoPlayerView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerView_iPhone.h"

@implementation SNVideoPlayerView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_finishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		
		//_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/gutz/video/device-demo_[08.30.2011]-485kbs.mov"]];
		_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
		_playerController.controlStyle = MPMovieControlStyleNone;
		_playerController.view.frame = frame;
		_playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_playerController.shouldAutoplay = NO;
		_playerController.allowsAirPlay = YES;
		[_playerController setFullscreen:NO];
		[_playerController play];
		[self addSubview:_playerController.view];	
	}
	
	return (self);
}


#pragma mark - Notification handlers
-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----STARTED PLAYBACK----");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];    	
}

-(void)_finishedCallback:(NSNotification *)notification {
	NSLog(@"----FINISHED PLAYBACK----");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];    
	[_playerController autorelease];
}

@end
