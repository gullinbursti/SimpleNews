//
//  SNSplashViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNSplashViewController_iPhone.h"
#import "SNRootViewController_iPhone.h"

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
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	_logoImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(118, 198, 84.0, 84.0)] autorelease];
	_logoImgView.image = [UIImage imageNamed:@"logo_01.png"];
	[self.view addSubview:_logoImgView];
	
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
		
		SNRootViewController_iPhone *rootViewController = [[[SNRootViewController_iPhone alloc] init] autorelease];
		UINavigationController *rootNavigationController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
		[rootNavigationController setNavigationBarHidden:YES animated:NO];
		[self.navigationController pushViewController:rootViewController animated:NO];
	}
	
	_logoImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"logo_0%d.png", _frameIndex]];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
