//
//  SNArticleListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleListViewController_iPhone.h"
#import "SNArticleCardView_iPhone.h"

#import "SNAppDelegate.h"

@interface SNArticleListViewController_iPhone()
-(void)_goBack;
@end

@implementation SNArticleListViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"followerID"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	
}

-(void)dealloc {
	//[_articles release];
	[_overlayView release];
	[_gridButton release];
	
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = YES;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
	[self.view addSubview:_scrollView];
	
	//_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
	//[self.view addSubview:_overlayView];
	
	_gridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_gridButton.frame = CGRectMake(4.0, 4.0, 34.0, 34.0);
	[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridButton_nonActive.png"] forState:UIControlStateNormal];
	[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridButton_Active.png"] forState:UIControlStateHighlighted];
	[_gridButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_gridButton];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ARTICLES_RETURN" object:nil];	
	[self.navigationController popViewControllerAnimated:YES];
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
}



#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleListViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSArray *parsedArticles = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSMutableArray *articleList = [NSMutableArray array];
			_cardViews = [NSMutableArray new];
			
			SNArticleCardView_iPhone *followerItemView = [[[SNArticleCardView_iPhone alloc] initWithFrame:CGRectMake(0.0, 50.0, 80.0, 80.0) articleVO:nil] autorelease];
			[_cardViews addObject:followerItemView];
			
			int tot = 0;
			for (NSDictionary *serverArticle in parsedArticles) {
				SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
				
				NSLog(@"ARTICLE \"%@\"", vo.title);
				
				if (vo != nil)
					[articleList addObject:vo];
				
				SNArticleCardView_iPhone *articleCardView = [[[SNArticleCardView_iPhone alloc] initWithFrame:CGRectMake(self.view.frame.size.width * tot, 0.0, self.view.frame.size.width, self.view.frame.size.height) articleVO:vo] autorelease];
				[_cardViews addObject:articleCardView];
				tot++;
			}
			
			_articles = [articleList retain];
			[articleList release];
			
			for (SNArticleCardView_iPhone *cardView in _cardViews)
				[_scrollView addSubview:cardView];
			
			_scrollView.contentSize = CGSizeMake(self.view.frame.size.width * [_articles count], self.view.frame.size.height);
		}
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	
	if (request == _articlesRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}


/*
 -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

@end
