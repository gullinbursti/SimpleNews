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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoDuration:) name:@"VIDEO_DURATION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoSize:) name:@"VIDEO_SIZE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	[self.view setBackgroundColor:[UIColor colorWithWhite:0.145 alpha:1.0]];
	
	_videoPlayerView = [[[SNVideoPlayerView_Airplay alloc] initWithFrame:CGRectMake(0.0, 0.0, 1280.0, 720.0)] autorelease];
	[self.view addSubview:_videoPlayerView];
		
	_gadgetsView = [[SNGadgetsView_Airplay alloc] initWithFrame:CGRectMake(0.0, 0.0, 256.0, 720.0)];
	[self.view addSubview:_gadgetsView];
	
	_hdLogoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(1200.0, 650.0, 64.0, 64.0)];
	_hdLogoImgView.image = [UIImage imageNamed:@"hd-logo.png"];
	_hdLogoImgView.hidden = YES;
	[self.view addSubview:_hdLogoImgView];
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
}


#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	_hdLogoImgView.hidden = YES;
}

-(void)_videoDuration:(NSNotification *)notification {
}

-(void)_videoSize:(NSNotification *)notification {
	_hdLogoImgView.hidden = ( [[notification object] floatValue] < 720.0);
}

-(void)_videoEnded:(NSNotification *)notification {
}


@end
