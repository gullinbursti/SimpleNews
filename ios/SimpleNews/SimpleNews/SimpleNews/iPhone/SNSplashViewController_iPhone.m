//
//  SNSplashViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNSplashViewController_iPhone.h"

#import "SNVideoListViewController_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNSplashViewController_iPhone

-(id)init {
	if ((self = [super init])) {
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
	_progressView.frame = CGRectMake(277, 20, 28, 28);
	[(UIActivityIndicatorView *)_progressView startAnimating];
	[self.view addSubview:_progressView];
	
	_logoView = [[UIView alloc] initWithFrame:CGRectMake(27, 374, 56, 56)];
	[_logoView setBackgroundColor:[UIColor blueColor]];
	[self.view addSubview:_logoView];
	
	UILabel *logoCharLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, -4, 56, 56)] autorelease];
	logoCharLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:40.0];
	logoCharLabel.backgroundColor = [UIColor clearColor];
	logoCharLabel.textColor = [UIColor blackColor];
	logoCharLabel.textAlignment = UITextAlignmentCenter;
	logoCharLabel.text = @"a";
	[_logoView addSubview:logoCharLabel];
	
	UILabel *logoNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(27, 442, 200, 20)] autorelease];
	logoNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16.0];
	logoNameLabel.backgroundColor = [UIColor clearColor];
	logoNameLabel.textColor = [UIColor whiteColor];
	logoCharLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	logoCharLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	logoNameLabel.text = @"news network";
	[self.view addSubview:logoNameLabel];
	
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
			
			//[self.navigationController presentViewController:[[[SNVideoListViewController_iPhone alloc] initWithUserInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]] autorelease] animated:YES completion:nil];
			
			//SNVideoListViewController_iPhone *videoListViewController = [[[SNVideoListViewController_iPhone alloc] initWithUserInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]] autorelease];
			//UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:videoListViewController] autorelease];
			//[self.navigationController pushViewController:navigationController animated:YES];	
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				self.view.frame = CGRectMake(-self.view.bounds.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
			}];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:nil];
			[self presentViewController:[[[SNVideoListViewController_iPhone alloc] initWithUserInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]] autorelease] animated:NO completion:nil];
		}
	}];
}

@end
