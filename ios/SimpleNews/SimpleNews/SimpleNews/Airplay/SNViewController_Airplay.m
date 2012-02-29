//
//  SNAirplayViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNViewController_Airplay.h"

#import "SNVideoItemVO.h"

@implementation SNViewController_Airplay

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super init])) {
		self.view.frame = frame;
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	CGRect frame = CGRectMake(0.0, 360.0, 1280.0, 720.0);
	
	UIView *holderView = [[[UIView alloc] initWithFrame:frame] autorelease];
	[holderView setBackgroundColor:[UIColor yellowColor]];
	[self.view addSubview:holderView];
	
	//_videoPlayerView = [[[SNVideoPlayerView_Airplay alloc] initWithFrame:CGRectMake(100.0, 360.0, 1024.0, 576.0)] autorelease];
	_videoPlayerView = [[[SNVideoPlayerView_Airplay alloc] initWithFrame:frame] autorelease];
	[holderView addSubview:_videoPlayerView];
	
	_logoView = [[SNLogoView alloc] initAtPosition:CGPointMake(27.0, 650.0)];
	[self.view addSubview:_logoView];
	
	_clockView = [[SNClockView alloc] initAtPosition:CGPointMake(1290.0, 700.0)];
	[self.view addSubview:_clockView];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[UIView animateWithDuration:1.0 animations:^(void) {
		_videoPlayerView.frame = CGRectMake(_videoPlayerView.frame.origin.x, -360.0, _videoPlayerView.frame.size.width, _videoPlayerView.frame.size.height);;
	}];
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		_clockView.frame = CGRectMake(1100.0, _clockView.frame.origin.y, _clockView.frame.size.width, _clockView.frame.size.height);
	}];
}


#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	
	NSLog(@"VIDEO CHANGE:[%@]", vo.video_title);
	//[_videoPlayerView togglePlayback:YES];
}

@end
