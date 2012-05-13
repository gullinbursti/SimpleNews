//
//  SNSplashViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNSplashViewController_iPhone.h"
#import "SNRootViewController_iPhone.h"

#import "SNAppDelegate.h"

@interface SNSplashViewController_iPhone()
@end

@implementation SNSplashViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_frameIndex = 1;
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
		  
-(void)dealloc {
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	_logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(127.0, 170.0, 64.0, 64.0)];
	_logoImgView.image = [UIImage imageNamed:@"logoLoader_001.png"];
	[self.view addSubview:_logoImgView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 245.0, 120.0, 16.0)];
	titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = @"Assembling content";
	[self.view addSubview:titleLabel];
	
	UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 263.0, 220.0, 16.0)];
	subtitleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12];
	subtitleLabel.textColor = [UIColor colorWithWhite:0.545 alpha:1.0];
	subtitleLabel.backgroundColor = [UIColor clearColor];
	subtitleLabel.textAlignment = UITextAlignmentCenter;
	subtitleLabel.text = @"from the last 24 hours…";
	[self.view addSubview:subtitleLabel];
	
	_frameTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(_nextFrame) userInfo:nil repeats:YES];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


-(void)_nextFrame {
	//NSLog(@"TIMER TICK");
	
	_frameIndex++;
	
	if (_frameIndex == 6 * 3) {
		[_frameTimer invalidate];
		_frameTimer = nil;
		
		[self.navigationController pushViewController:[[SNRootViewController_iPhone alloc] init] animated:YES];
	}
	
	_logoImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"logoLoader_00%d.png", (_frameIndex % 6) + 1]];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
