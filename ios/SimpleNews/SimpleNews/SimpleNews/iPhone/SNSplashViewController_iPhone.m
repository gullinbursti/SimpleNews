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
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	_logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(93, 130, 134.0, 134.0)];
	_logoImgView.image = [UIImage imageNamed:@"logoLoader_001.png"];
	[self.view addSubview:_logoImgView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 285.0, 120.0, 18.0)];
	titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
	titleLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = @"Assembling news";
	[self.view addSubview:titleLabel];
	
	UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 308.0, 220.0, 18.0)];
	subtitleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	subtitleLabel.textColor = [UIColor colorWithWhite:0.545 alpha:1.0];
	subtitleLabel.backgroundColor = [UIColor clearColor];
	subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
	subtitleLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
	subtitleLabel.textAlignment = UITextAlignmentCenter;
	subtitleLabel.text = @"from the last 24 hours…";
	[self.view addSubview:subtitleLabel];
	
	_frameTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(_nextFrame) userInfo:nil repeats:YES];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


-(void)_nextFrame {
	NSLog(@"TIMER TICK");
	
	_frameIndex++;
	
	if (_frameIndex == 7) {
		[_frameTimer invalidate];
		_frameTimer = nil;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SPLASH_DISMISSED" object:nil];
		
		SNRootViewController_iPhone *rootViewController = [[SNRootViewController_iPhone alloc] init];
		UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
		[rootNavigationController setNavigationBarHidden:YES animated:NO];
		[self.navigationController pushViewController:rootViewController animated:YES];
	}
	
	_logoImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"logoLoader_00%d.png", _frameIndex]];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
