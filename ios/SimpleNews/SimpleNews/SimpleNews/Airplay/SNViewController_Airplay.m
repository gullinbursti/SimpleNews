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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		
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
	
	_videoPlayerView = [[[SNVideoPlayerView_Airplay alloc] initWithFrame:CGRectMake(0.0, 360.0, 1280.0, 720.0)] autorelease];
	[self.view addSubview:_videoPlayerView];
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
		CGRect frame = _videoPlayerView.frame;
		frame.origin.y = -360.0;
		
		_videoPlayerView.frame = frame;
		
	} completion:^(BOOL finished) {
		//[_videoPlayerView togglePlayback:YES];
	}];
}


#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	
	NSLog(@"VIDEO CHANGE:[%@]", vo.video_title);
	[_videoPlayerView togglePlayback:YES];
}

@end
