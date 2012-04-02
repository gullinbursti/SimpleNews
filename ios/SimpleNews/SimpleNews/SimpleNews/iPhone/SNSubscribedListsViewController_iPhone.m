//
//  SNSubscribedListsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNSubscribedListsViewController_iPhone.h"

#import "SNAppDelegate.h"
#import "SNListVO.h"
#import "SNListCardView_iPhone.h"
#import "SNArticleListViewController_iPhone.h"

@interface SNSubscribedListsViewController_iPhone()
-(void)_goArticles;
@end

@implementation SNSubscribedListsViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_listArticles:) name:@"LIST_ARTICLES" object:nil];
		
		
		_subscribedLists = [NSMutableArray new];
		
		_listsRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
		[_listsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		//[_listsRequest setPostValue:[[SNAppDelegate fbProfile] objectForKey:@"id"] forKey:@"userID"];
		[_listsRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"userID"];
		[_listsRequest setTimeOutSeconds:30];
		[_listsRequest setDelegate:self];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LIST_ARTICLES" object:nil];
	
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	_holderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_holderView];

	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	[self.view addSubview:_scrollView];
	
	
	UIButton *greyGridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	greyGridButton.frame = CGRectMake(4.0, 0.0, 44.0, 44.0);
	[greyGridButton setBackgroundImage:[UIImage imageNamed:@"gridIconGray_nonActive.png"] forState:UIControlStateNormal];
	[greyGridButton setBackgroundImage:[UIImage imageNamed:@"gridIconGray_Active.png"] forState:UIControlStateHighlighted];
	[greyGridButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:greyGridButton];
		
	[_listsRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];	
}

-(void)_goArticles {
	[self.navigationController pushViewController:[[[SNArticleListViewController_iPhone alloc] initAsMostRecent] autorelease] animated:NO];	
}


#pragma mark - Notification handlers
-(void)_listArticles:(NSNotification *)notification {
	[self.navigationController pushViewController:[[[SNArticleListViewController_iPhone alloc] initAsMostRecent] autorelease] animated:NO];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNSubscribedListsViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
			
			_subscribedLists = [list retain];
			
			int cnt = 0;
			for (SNListVO *vo in _subscribedLists) {
				SNListCardView_iPhone *listCardView = [[[SNListCardView_iPhone alloc] initWithFrame:CGRectMake(cnt * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) listVO:vo] autorelease];
				[_scrollView addSubview:listCardView];
				
				cnt++;
			}
			
			_scrollView.contentSize = CGSizeMake([_subscribedLists count] * self.view.frame.size.width, self.view.frame.size.height);
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
