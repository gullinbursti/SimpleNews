//
//  SNOptionsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNOptionsViewController_iPhone.h"

#import "SNOptionItemView_iPhone.h"
#import "SNOptionVO.h"

#import "SNAppDelegate.h"

@implementation SNOptionsViewController_iPhone

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


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	_optionViews = [[NSMutableArray alloc] init];
	_optionVOs = [[NSMutableArray alloc] init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 56.0, self.view.frame.size.width, self.view.frame.size.height)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = NO;
	_scrollView.scrollsToTop = YES;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
	_scrollView.contentOffset = CGPointMake(0.0, 0.0);
	_scrollView.contentSize = self.view.frame.size;
	[self.view addSubview:_scrollView];
	
	NSString *testOptionsPath = [[NSBundle mainBundle] pathForResource:@"options" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testOptionsPath] options:NSPropertyListImmutable format:nil error:nil];
	
	int cnt = 0;
	for (NSDictionary *testOption in plist) {
		SNOptionVO *vo = [SNOptionVO optionWithDictionary:testOption];
		SNOptionItemView_iPhone *itemView = [[[SNOptionItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, cnt * 64, self.view.frame.size.width, 64) withVO:vo] autorelease];
		
		[_optionViews addObject:itemView];
		[_optionVOs addObject:vo];
		[_scrollView addSubview:itemView];
		cnt++;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, cnt * 64);
	
	
	UIButton *backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	backButton.frame = CGRectMake(254.0, 4.0, 64.0, 34.0);
	[backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	backButton.titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12.0];
	backButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	backButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	backButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[backButton setTitle:@"Done" forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
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



#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"OPTIONS_RETURN" object:nil];
	[self dismissModalViewControllerAnimated:YES];
}


-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	NSLog(@"SWIPE @:(%f, %d)", translatedPoint.x, abs(translatedPoint.y));
	
	
	//if (translatedPoint.x < -20 && abs(translatedPoint.y) < 30) {
	//	[self _goBack];
	//}
}


#pragma mark - Notification handlers
/*
 -(void)_deviceSelected:(NSNotification *)notification {
 SNDeviceVO *vo = (SNDeviceVO *)[notification object];
 
 if (vo.type_id != 4) {
 for (SNDeviceItemView_iPhone *deviceItemView in _deviceViews) {
 if (deviceItemView.vo != vo)
 [deviceItemView deselect];
 }
 }
 
 [self performSelector:@selector(_goBack) withObject:nil afterDelay:0.25];
 }
 */

@end
