//
//  SNVideoPlayerView_Airplay.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerView_Airplay.h"

@implementation SNVideoPlayerView_Airplay

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_finishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_stateChangedCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		
		
		//_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://o-o.preferred.comcast-lax1.v17.lscache8.c.youtube.com/videoplayback?sparams=id%2Cexpire%2Cip%2Cipbits%2Citag%2Csource%2Cratebypass%2Ccp&fexp=902906%2C916103%2C913533&itag=22&ip=98.0.0.0&signature=4001D0E6970AB574B9264BECB835C3CA9CF597A3.75D481B6D6A72C5252F367FFF42942C14B6CAAC4&sver=3&ratebypass=yes&source=youtube&expire=1329818607&key=yt1&ipbits=8&cp=U0hRTlhMVl9FUUNOMV9QRlpHOkJiZzNwU190SVlE&id=c15baec91181fc10&title=Duke%20Nukem%20Forever%20Official%20HD%20Debut%20Trailer"]];
		//_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/gutz/video/device-demo_[08.30.2011]-485kbs.mov"]];
		_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
		_playerController.controlStyle = MPMovieControlStyleNone;
		_playerController.view.frame = frame;
		_playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_playerController.shouldAutoplay = NO;
		_playerController.allowsAirPlay = YES;
		_playerController.movieSourceType = MPMovieSourceTypeFile;
		[_playerController prepareToPlay];
		[_playerController setFullscreen:NO];
		//[_playerController play];
		[self addSubview:_playerController.view];
	}
	
	return (self);
}


-(void)togglePlayback:(BOOL)isPlaying {
	//[_playerController stop];
	//[_playerController setContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
	[_playerController setContentURL:[NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/gutz/video/device-demo_[08.30.2011]-485kbs.mov"]];
	
	[_playerController play];
}


#pragma mark - Notification handlers
-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----STARTED PLAYBACK----(%f)", _playerController.endPlaybackTime);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
}

-(void)_finishedCallback:(NSNotification *)notification {
	NSLog(@"----FINISHED PLAYBACK----");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];    
	[_playerController autorelease];
}

-(void)_stateChangedCallback:(NSNotification *)notification {
	NSLog(@"----STATE CHANGED----");
	
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

@end
