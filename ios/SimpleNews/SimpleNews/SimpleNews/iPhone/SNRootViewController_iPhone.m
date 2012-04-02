//
//  SNRootViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNRootViewController_iPhone.h"
#import "SNListItemView_iPhone.h"
#import "SNListVO.h"

#import "SNSubscribedListsViewController_iPhone.h"
#import "SNArticleListViewController_iPhone.h"
#import "SNAppDelegate.h"

@interface SNRootViewController_iPhone()
-(void)_goLists;
@end

@implementation SNRootViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_lists = [NSMutableArray new];
		
		_listsRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
		[_listsRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
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
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
	bgImgView.image = [UIImage imageNamed:@"background.jpg"];
	[self.view addSubview:bgImgView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:_scrollView];
	
	UIButton *articlesButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	articlesButton.frame = CGRectMake(250.0, 12.0, 64.0, 34.0);
	[articlesButton setBackgroundImage:[[UIImage imageNamed:@"doneButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[articlesButton setBackgroundImage:[[UIImage imageNamed:@"doneButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	articlesButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	articlesButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[articlesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	articlesButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	articlesButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[articlesButton setTitle:@"Lists" forState:UIControlStateNormal];
	[articlesButton addTarget:self action:@selector(_goLists) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:articlesButton];
	
	[_listsRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	[self _goLists];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goLists {
	[self.navigationController pushViewController:[[[SNSubscribedListsViewController_iPhone alloc] init] autorelease] animated:YES];
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
				SNListItemView_iPhone *listItemView = [[[SNListItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, cnt * 20.0, self.view.frame.size.width, 20.0) listVO:vo] autorelease];
				[_scrollView addSubview:listItemView];
				
				cnt++;
			}
			
			_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, cnt * 20.0);
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
