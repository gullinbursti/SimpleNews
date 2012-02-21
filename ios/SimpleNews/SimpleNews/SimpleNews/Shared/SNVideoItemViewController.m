//
//  SNVideoItemViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoItemViewController.h"

#import "SNAppDelegate.h"

@implementation SNVideoItemViewController

-(id)initWithVO:(SNVideoItemVO *)vo {
	if ((self = [super init])) {
		_vo = vo;
	}
	
	return (self);
}

-(void)dealloc {
	_imageView = nil;
	_titleLabel = nil;
	
	[super dealloc];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


-(void)togglePlayback:(BOOL)isPlaying {
	if (isPlaying) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_finishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		
		[_playerController play];
	
	} else {
		
	}
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 192.0)];
	_imageView.imageURL = [NSURL URLWithString:_vo.image_url];
	_imageView.alpha = 0.5;
	_imageView.clipsToBounds = YES;
	[self.view addSubview:_imageView];
	
	/*
	//_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://dev.gullinbursti.cc/projs/gutz/video/device-demo_[08.30.2011]-485kbs.mov"]];
	_playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
	_playerController.controlStyle = MPMovieControlStyleNone;
	_playerController.view.frame = CGRectMake(0.0, 0.0, 320, 192);
	_playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_playerController.shouldAutoplay = NO;
	_playerController.allowsAirPlay = YES;
	[_playerController setFullscreen:NO];
	[self.view addSubview:_playerController.view];
	*/
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, 20)];
	_titleLabel.font = [[SNAppDelegate snHelveticaFontBold] fontWithSize:14.0];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textColor = [UIColor whiteColor];
	//_titleLabel.textAlignment = UITextAlignmentCenter;
	_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	_titleLabel.text = _vo.video_title;
	[self.view addSubview:_titleLabel];
	
	UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 190.0, self.view.frame.size.width, 1.0)] autorelease];
	[lineView setBackgroundColor:[UIColor whiteColor]];
	
	[self.view addSubview:lineView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
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
