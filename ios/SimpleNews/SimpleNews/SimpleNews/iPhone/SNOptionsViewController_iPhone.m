//
//  SNOptionsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "SNOptionsViewController_iPhone.h"

#import "SNOptionItemView_iPhone.h"
#import "SNOptionVO.h"

#import "SNAppDelegate.h"

#import "SNOptionsPageViewController.h"

@implementation SNOptionsViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_optionSelected:) name:@"OPTION_SELECTED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_optionDeselected:) name:@"OPTION_DESELECTED" object:nil];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"OPTION_SELECTED" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"OPTION_DESELECTED" object:nil];
	
	[super dealloc];
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	_optionViews = [[NSMutableArray alloc] init];
	_optionVOs = [[NSMutableArray alloc] init];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	
	UIImageView *headerImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 56.0)] autorelease];
	headerImgView.image = [UIImage imageNamed:@"subheaderBG.png"];
	[self.view addSubview:headerImgView];
	
	
	UIImageView *titleImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(100.0, 21.0, 114.0, 14.0)] autorelease];
	titleImgView.image = [UIImage imageNamed:@"titleOptions.png"];
	[self.view addSubview:titleImgView];
	
	
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
		
		if (vo.option_id == 3 && [SNAppDelegate notificationsEnabled])
			[itemView toggleSelected:YES];
		
		[_optionViews addObject:itemView];
		[_optionVOs addObject:vo];
		[_scrollView addSubview:itemView];
		cnt++;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, cnt * 64);
	
	UIButton *backButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	backButton.frame = CGRectMake(12.0, 12.0, 64.0, 34.0);
	[backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	backButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	backButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	backButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 4.0, 0.0, -4.0);
	backButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	backButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[backButton setTitle:@"Back" forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
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
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notification handlers
-(void)_optionSelected:(NSNotification *)notification {
	SNOptionVO *vo = (SNOptionVO *)[notification object];
 	
	SNOptionsPageViewController *optionsPageViewController;
	TWTweetComposeViewController *twitter;
	
	switch (vo.option_id) {
		case 1:
			break;
			
		case 2:
			twitter = [[[TWTweetComposeViewController alloc] init] autorelease];
			[twitter addURL:[NSURL URLWithString:[NSString stringWithString:vo.option_url]]];
			[twitter setInitialText:vo.option_info];
			[self presentModalViewController:twitter animated:YES];
			
			twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) {
				
				if (result == TWTweetComposeViewControllerResultDone)
					[SNAppDelegate twitterToggle:YES];
				
				else if (result == TWTweetComposeViewControllerResultCancelled)
					[SNAppDelegate twitterToggle:NO];
				
				[self dismissModalViewControllerAnimated:YES];
			};	
			break;
			
		case 3:
			[SNAppDelegate notificationsToggle:YES];
			break;
			
		case 4:
			optionsPageViewController = [[[SNOptionsPageViewController alloc] initWithURL:[NSURL URLWithString:vo.option_url]] autorelease];
			[self.navigationController setNavigationBarHidden:YES];
			[self.navigationController pushViewController:optionsPageViewController animated:YES];
			break;
			
		case 5:
			optionsPageViewController = [[[SNOptionsPageViewController alloc] initWithURL:[NSURL URLWithString:vo.option_url]] autorelease];
			[self.navigationController setNavigationBarHidden:YES];
			[self.navigationController pushViewController:optionsPageViewController animated:YES];
			break;
 	}
}

-(void)_optionDeselected:(NSNotification *)notification {
	SNOptionVO *vo = (SNOptionVO *)[notification object];
	
	if (vo.option_id == 2) {
		[SNAppDelegate notificationsToggle:NO];
 	}
}

@end
