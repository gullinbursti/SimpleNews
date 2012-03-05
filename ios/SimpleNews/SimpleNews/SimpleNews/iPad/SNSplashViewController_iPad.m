//
//  SNSplashViewController_iPad.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.02.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNSplashViewController_iPad.h"

#import "SNVideoGridViewController_iPad.h"

@interface SNSplashViewController_iPad()
-(void)_introComplete:(NSNotification *)notification;
@end

@implementation SNSplashViewController_iPad

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_introComplete:) name:@"INTRO_COMPLETE" object:nil];
		_photoSlides = [[NSMutableArray alloc] initWithObjects:@"loader_Image01_Business-iPhone.jpg", @"loader_Image01_Tech-iPhone.jpg", @"loader_Image01_Trending-iPhone.jpg", @"loader_Image03_Sports-iPhone.jpg", nil];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	_holderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_holderView];
	
	_progressView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	_progressView.frame = CGRectMake(self.view.frame.size.width - 48, 20, 28, 28);
	[(UIActivityIndicatorView *)_progressView startAnimating];
	[self.view addSubview:_progressView];
	
	_logoView = [[SNLogoView alloc] initAtPosition:CGPointMake(27, self.view.frame.size.height - 100.0)];
	[self.view addSubview:_logoView];
	
	_introImageView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	_introImageView.image = [UIImage imageNamed:[_photoSlides objectAtIndex:[_photoSlides count] - 1]];
	_introImageView.alpha = 0.0;
	[_holderView addSubview:_introImageView];
	
	_outroImageView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	_outroImageView.image = [UIImage imageNamed:[_photoSlides objectAtIndex:_timerCount]];
	_outroImageView.alpha = 0.0;
	[_holderView addSubview:_outroImageView];
	
	_timerCount = [_photoSlides count] - 1;
	_timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(_timerTick) userInfo:nil repeats:YES];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}




-(void)_timerTick {
	_introImageView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	_introImageView.image = [UIImage imageNamed:[_photoSlides objectAtIndex:_timerCount]];
	_introImageView.alpha = 0.0;
	[_holderView addSubview:_introImageView];
	
	[UIView animateWithDuration:0.85 animations:^(void) {
		_introImageView.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		
		_outroImageView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
		_outroImageView.image = [UIImage imageNamed:[_photoSlides objectAtIndex:_timerCount]];
		[_holderView addSubview:_outroImageView];
		
		_timerCount--;
		
		NSLog(@"TICK:[%d]", _timerCount);
		
		if (_timerCount == -1) {
			[_timer invalidate];
			_timer = nil;
			
			if ([[UIScreen screens] count] == 1) {
				[_progressView removeFromSuperview];
				
				_noAirplayView = [[SNNoAirplayView_iPhone alloc] init];
				[self.view addSubview:_noAirplayView];
				
			} else 
				[self _introComplete:nil];
		}
	}];
}


#pragma mark - Notification handlers
-(void)_introComplete:(NSNotification *)notification {
	
	//[self.navigationController presentViewController:[[[SNVideoListViewController_iPhone alloc] initWithUserInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]] autorelease] animated:YES completion:nil];
	
	//SNVideoListViewController_iPhone *videoListViewController = [[[SNVideoListViewController_iPhone alloc] initWithUserInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]] autorelease];
	//UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:videoListViewController] autorelease];
	//[self.navigationController pushViewController:navigationController animated:YES];	
	
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		self.view.frame = CGRectMake(-self.view.bounds.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	}];
	
	[self presentViewController:[[[SNVideoGridViewController_iPad alloc] init] autorelease] animated:NO completion:nil];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
