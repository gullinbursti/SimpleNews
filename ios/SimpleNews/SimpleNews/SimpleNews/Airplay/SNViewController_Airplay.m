//
//  SNAirplayViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNViewController_Airplay.h"

#import "SNVideoItemVO.h"
#import "UIImage+StackBlur.h"

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
	
	_videoPlayerView = [[[SNVideoPlayerView_Airplay alloc] initWithFrame:CGRectMake(0.0, 0.0, 1280.0, 720.0)] autorelease];
	[self.view addSubview:_videoPlayerView];
		
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
	
	//[UIView animateWithDuration:1.0 animations:^(void) {
	//	_videoPlayerView.frame = CGRectMake(_videoPlayerView.frame.origin.x, -360.0, _videoPlayerView.frame.size.width, _videoPlayerView.frame.size.height);;
	//}];
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		_clockView.frame = CGRectMake(1100.0, _clockView.frame.origin.y, _clockView.frame.size.width, _clockView.frame.size.height);
	}];
}


#pragma mark - Notification handlers

@end
