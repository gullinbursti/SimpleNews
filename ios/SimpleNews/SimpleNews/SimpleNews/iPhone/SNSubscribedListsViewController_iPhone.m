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

#import "SNFinalListCardView_iPhone.h"
#import "SNWebPageViewController_iPhone.h"

@interface SNSubscribedListsViewController_iPhone()
@end

@implementation SNSubscribedListsViewController_iPhone

-(id)initWithAnimation:(BOOL)intro {
	if ((self = [super init])) {
		_isIntroed = intro;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_listArticles:) name:@"LIST_ARTICLES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE2" object:nil];
		
		_subscribedLists = [NSMutableArray new];
		
		_listsRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]] retain];
		[_listsRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"action"];
		if ([[SNAppDelegate profileForUser] objectForKey:@"id"])
			[_listsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		
		else
			[_listsRequest setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"userID"];
		[_listsRequest setDelegate:self];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LIST_ARTICLES" object:nil];
	
	[_paginationView release];
	
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	bgImgView.image = [UIImage imageNamed:@"background_stripes.png"];
	[self.view addSubview:bgImgView];
	
	UIImageView *logoImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(118, 198, 84.0, 84.0)] autorelease];
	logoImgView.image = [UIImage imageNamed:@"logo_01.png"];
	[self.view addSubview:logoImgView];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(320.0 * (int)_isIntroed, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_holderView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = YES;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	[_holderView addSubview:_scrollView];
	
	_rootListButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_rootListButton.frame = CGRectMake(-64.0, -64.0, 64.0, 64.0);
	[_rootListButton setBackgroundImage:[UIImage imageNamed:@"topLeft_nonActive.png"] forState:UIControlStateNormal];
	[_rootListButton setBackgroundImage:[UIImage imageNamed:@"topLeft_Active.png"] forState:UIControlStateHighlighted];
	[_rootListButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_rootListButton];
	
	_paginationView = [[SNPaginationView_iPhone alloc] initWithFrame:CGRectMake(136.0, 467.0, 48.0, 9.0)];
	[_holderView addSubview:_paginationView];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	[_listsRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_holderView.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
		
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.33 animations:^(void) {
			_rootListButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
		} completion:nil];
	}];
	
	[super viewDidAppear:animated];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notification handlers
-(void)_listArticles:(NSNotification *)notification {
	SNListVO *vo = (SNListVO *)[notification object];
	
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
		[alert show];
		[alert release];
	
	} else {
		//[UIView animateWithDuration:0.33 animations:^(void) {
		//	_rootListButton.frame = CGRectMake(-64.0, -64.0, 64.0, 64.0);
	
		//} completion:^(BOOL finished) {
			[self.navigationController pushViewController:[[[SNArticleListViewController_iPhone alloc] initWithListVO:vo] autorelease] animated:YES];
		//}];
	}
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController_iPhone *webPageViewController = [[[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {	
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[_paginationView changePage:round((([_subscribedLists count] - 1) - (scrollView.contentOffset.x / 320.0)) / 3)];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNSubscribedListsViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
		NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		NSArray *parsedLists = [unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		NSMutableArray *finalList = [NSMutableArray new];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNListVO *vo = [SNListVO listWithDictionary:serverList];
				NSLog(@"LIST \"@%@\" %d [%d]", vo.list_name, vo.totalInfluencers, vo.isSubscribed);
				
				if (vo != nil)
					[list addObject:vo];
			}
			
			_subscribedLists = [list retain];
			
			int cnt = 0;
			for (SNListVO *vo in _subscribedLists) {
				if (cnt < 3) {
					SNListCardView_iPhone *listCardView = [[[SNListCardView_iPhone alloc] initWithFrame:CGRectMake(cnt * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) listVO:vo] autorelease];
					[_scrollView addSubview:listCardView];
					cnt++;
					
				} else {
					[finalList addObject:vo];
				}
			}
			
			SNFinalListCardView_iPhone *finalListCardView = [[[SNFinalListCardView_iPhone alloc] initWithFrame:CGRectMake(cnt * self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height) addlLists:finalList] autorelease];
			[_scrollView addSubview:finalListCardView];
			
			_scrollView.contentSize = CGSizeMake((cnt + 1) * self.view.frame.size.width, self.view.frame.size.height);
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
