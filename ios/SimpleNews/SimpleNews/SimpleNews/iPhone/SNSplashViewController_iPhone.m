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
-(void)_goNextCell;
-(void)_goGrid;
@end

@implementation SNSplashViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_cnt = 0;	
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
	[self.navigationController pushViewController:[[[SNFollowerGridViewController_iPhone alloc] init] autorelease] animated:NO];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	_bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	_bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:_bgImgView];
	
	_highlightView = [[SNSplashHighlightView alloc] init];
	[self.view addSubview:_highlightView];
	
	UIImageView *logoImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(53.0, 228.0, 214.0, 24.0)] autorelease];
	logoImgView.image = [UIImage imageNamed:@"logo.png"];
	[self.view addSubview:logoImgView];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_goNextCell) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)_goNextCell {
	_cnt++;
	
	if (_cnt == 2) {
		[_timer invalidate];
		_timer = nil;
		
		[self performSelector:@selector(_goGrid) withObject:self afterDelay:0.5];
	}
	
	int rndCell = arc4random() % 24;
	int row = rndCell / 6;
	int col = rndCell % 4;
	
	NSLog(@"NEXT CELL(%d, %d)", col, row);
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_highlightView.frame = CGRectMake(col * 80.0, row * 80.0, 80.0, 80.0);
	}];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
