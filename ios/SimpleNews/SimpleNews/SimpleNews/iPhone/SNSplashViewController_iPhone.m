//
//  SNSplashViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNSplashViewController_iPhone.h"
#import "SNFollowerGridViewController_iPhone.h"

@interface SNSplashViewController_iPhone()
-(void)_goGrid;
@end

@implementation SNSplashViewController_iPhone

-(id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
		  
-(void)dealloc {
	[super dealloc];
}

-(void)_goGrid {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SPLASH_DISMISSED" object:nil];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	_bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	_bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:_bgImgView];
	
	_stripsImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -self.view.frame.size.height + 20.0, self.view.frame.size.width, self.view.frame.size.height)];
	_stripsImgView.image = [UIImage imageNamed:@"loaderBG.jpg"];
	[self.view addSubview:_stripsImgView];
	
	_highlightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 12.0, 74.0, 9.0)];
	_highlightImgView.image = [UIImage imageNamed:@"loaderHighlight.png"];
	[self.view addSubview:_highlightImgView];
	
	UIImageView *logoImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(53.0, 228.0, 214.0, 24.0)] autorelease];
	logoImgView.image = [UIImage imageNamed:@"logo.png"];
	[self.view addSubview:logoImgView];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	
	[UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
		_highlightImgView.frame = CGRectMake(self.view.frame.size.width, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_highlightImgView.frame = CGRectMake(0.0, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
		
		[UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
			_highlightImgView.frame = CGRectMake(self.view.frame.size.width, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
			
		} completion:^(BOOL finished) {
			_highlightImgView.frame = CGRectMake(0.0, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
			
			[UIView animateWithDuration:0.67 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
				_stripsImgView.frame = CGRectMake(0.0, 0.0, _stripsImgView.frame.size.width, _stripsImgView.frame.size.height);
				
			} completion:^(BOOL finished) {
				[self _goGrid];
			}];
		}];
	}];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
