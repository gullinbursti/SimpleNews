//
//  SNTestVideoView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.05.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTestVideoView.h"

@implementation SNTestVideoView

@synthesize mpc;

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
		self.mpc = mp;
		[mp release];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_finishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_airplayActiveCallback:) name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:nil];
		
		self.mpc.controlStyle = MPMovieControlStyleDefault;
		self.mpc.view.frame = self.frame;
		self.mpc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.mpc.shouldAutoplay = YES;
		self.mpc.allowsAirPlay = YES;
		self.mpc.movieSourceType = MPMovieSourceTypeFile;
		[self.mpc prepareToPlay];
		[self.mpc setFullscreen:NO];
		self.mpc.view.hidden = YES;
	}
	
	return (self);
}


-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----[STARTED PLAYBACK]----");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
}

-(void)_finishedCallback:(NSNotification *)notification {
	NSLog(@"----[FINISHED PLAYBACK](%d)----", (self.mpc.currentPlaybackTime > self.mpc.duration - 1.5));
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		
	[self.mpc.view removeFromSuperview];
}

-(void)_airplayActiveCallback:(NSNotification *)notification {
	NSLog(@"----[AIRPLAY ACTIVE[%d]]----", self.mpc.airPlayVideoActive);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:nil];
	
	if (self.mpc.airPlayVideoActive)
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"airplay_enabled"];
	
	else
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"airplay_enabled"];
	
	[self.mpc stop];
}


@end
