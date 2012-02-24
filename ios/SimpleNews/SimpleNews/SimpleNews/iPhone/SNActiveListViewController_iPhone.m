//
//  SNActiveListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNActiveListViewController_iPhone.h"
#import "SNVideoItemVO.h"

#import "EGOImageView.h"

@implementation SNActiveListViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoProgression:) name:@"VIDEO_PROGRESSION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchEntered:) name:@"SEARCH_ENTERED" object:nil];
		
		_items = [[NSMutableArray alloc] init];
		self.view.frame = CGRectMake(0.0, -30.0, self.view.frame.size.width, 100);
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
	//self.view.alpha = 0.67;
	
	_videoSearchView = [[SNVideoSearchView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 30.0)];
	[self.view addSubview:_videoSearchView];
	
	_imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 30.0, self.view.frame.size.width, 70.0)];
	[_imgView setBackgroundColor:[UIColor blueColor]];
	[self.view addSubview:_imgView];
	
	_progressBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 8.0)];
	[_progressBar setBackgroundColor:[UIColor greenColor]];
	_progressBar.clipsToBounds = YES;
	[self.view addSubview:_progressBar];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goPan:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	//[self.view addGestureRecognizer:panRecognizer];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}



#pragma mark - Notification handlers
-(void)_itemTapped:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	_imgView.imageURL = [NSURL URLWithString:vo.image_url];
}


-(void)_videoProgression:(NSNotification *)notification {
	float percent = [(NSNumber *)[notification object] floatValue] / 120;
	
	NSLog(@"PROGESS:[%.2f]", percent);
	
	_progressBar.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width * percent, 8.0);
}

-(void)_searchEntered:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		self.view.frame = CGRectMake(0.0, -30.0, self.view.frame.size.width, 100);
	}];
}



-(void)_goPan:(id)sender {
	CGPoint transPt = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	
	//NSLog(@"PULLED:[%f]", transPt.y);
	/*
	if (abs(transPt.x) < 10 && transPt.y > 30)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_PULLED" object:nil];
	
	if (abs(transPt.x) < 10 && transPt.y < -30)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_PUSHED" object:nil];
	*/
}

@end