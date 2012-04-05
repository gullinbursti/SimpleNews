//
//  SNRootViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNRootViewController_iPhone.h"
#import "SNListItemView_iPhone.h"
#import "SNListVO.h"
#import "SNOptionVO.h"

#import "SNSubscribedListsViewController_iPhone.h"
#import "SNArticleListViewController_iPhone.h"
#import "SNOptionItemView_iPhone.h"
#import "SNAppDelegate.h"

@interface SNRootViewController_iPhone()
-(void)_goLists;
@end

@implementation SNRootViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_lists = [NSMutableArray new];
		
		_listsRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
		[_listsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_listsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"userID"];
		[_listsRequest setTimeOutSeconds:30];
		[_listsRequest setDelegate:self];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	bgImgView.image = [UIImage imageNamed:@"background_stripes.png"];
	[self.view addSubview:bgImgView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(12.0, 7.0, self.view.frame.size.width - 24.0, self.view.frame.size.height - 29.0)];
	[_scrollView setBackgroundColor:[UIColor whiteColor]];
	_scrollView.layer.cornerRadius = 8.0;
	_scrollView.clipsToBounds = YES;
	_scrollView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
	_scrollView.layer.borderWidth = 1.0;
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width - 24.0, self.view.frame.size.height);
	[self.view addSubview:_scrollView];
	
	_articlesButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_articlesButton.frame = CGRectMake(320.0, -64.0, 64.0, 64.0);
	[_articlesButton setBackgroundImage:[[UIImage imageNamed:@"topRight_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[_articlesButton setBackgroundImage:[[UIImage imageNamed:@"topRight_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	[_articlesButton addTarget:self action:@selector(_goLists) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_articlesButton];
	
	[_listsRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	[self _goLists];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_articlesButton.frame = CGRectMake(256.0, 0.0, 64.0, 64.0);
	} completion:nil];
	
	[super viewDidAppear:animated];
}


#pragma mark - Navigation
-(void)_goLists {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_articlesButton.frame = CGRectMake(320.0, -64.0, 64.0, 64.0);
	} completion:^(BOOL finished) {
		[self.navigationController pushViewController:[[[SNSubscribedListsViewController_iPhone alloc] init] autorelease] animated:YES];
	}];
	
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNRootViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNListVO *vo = [SNListVO listWithDictionary:serverList];
				NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				
				if (vo != nil)
					[list addObject:vo];
			}
			
			_lists = [list retain];
			
			int cnt = 0;
			for (SNListVO *vo in _lists) {
				SNListItemView_iPhone *listItemView = [[[SNListItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, cnt * 70.0, self.view.frame.size.width, 70.0) listVO:vo] autorelease];
				[_scrollView addSubview:listItemView];
				
				cnt++;
			}
			
			NSString *testOptionsPath = [[NSBundle mainBundle] pathForResource:@"options" ofType:@"plist"];
			NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testOptionsPath] options:NSPropertyListImmutable format:nil error:nil];
			
			for (NSDictionary *testOption in plist) {
				SNOptionVO *vo = [SNOptionVO optionWithDictionary:testOption];
				SNOptionItemView_iPhone *itemView = [[[SNOptionItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, cnt * 70, self.view.frame.size.width, 64) withVO:vo] autorelease];
				
				//if (vo.option_id == 3 && [SNAppDelegate notificationsEnabled])
				//	[itemView toggleSelected:YES];
				
				//[_optionViews addObject:itemView];
				//[_optionVOs addObject:vo];
				[_scrollView addSubview:itemView];
				cnt++;
			}
			
			
			_scrollView.contentSize = CGSizeMake(self.view.frame.size.width - 24.0, cnt * 70.0);
		}
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	if (request == _listsRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}


@end
