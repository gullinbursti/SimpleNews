//
//  SNBaseTimelineViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 09.03.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNAppDelegate.h"
#import "SNBaseTimelineViewController.h"
#import "MBLAsyncResource.h"
#import "MBLResourceLoader.h"

@interface SNBaseTimelineViewController () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *articleListResource;
@property(nonatomic, strong) MBLAsyncResource *updateListResource;

- (void)_retrieveTopicList;
- (void)_updateTopicList;

- (void)_retrieveProfileListWithType:(int)type;
@end


@implementation SNBaseTimelineViewController

@synthesize articleListResource = _articleListResource;
@synthesize updateListResource = _updateListResource;


- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)reloadTableViewDataSource {
	_reloading = YES;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	//	if (_vo.topic_id == 0) {
	//		[self _updatePopularList];
	//	
	//	} else {
	//		NSLog(@"\n\n\n\n%d\n\n\n\n", _lastID);
	//		[self _updateTopicList];
	//	}
	
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.33];
} 

- (void)doneLoadingTableViewData {
	_reloading = NO;
	
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}

- (void)_retrieveTopicList {
	if (_articleListResource == nil) {
		//_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		//_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		//_progressHUD.labelText = NSLocalizedString(@"Loading Articles…", @"Status message when loading article list");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[formValues setObject:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.articleListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate dateWithTimeIntervalSinceNow:60.0]]; // 1 minute expiration for now
	}
}

- (void)_updateTopicList {
	if (_updateListResource == nil) {
		_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
		//_progressHUD.labelText = [NSString stringWithFormat:@"Assembling %@…", _vo.title];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 12] forKey:@"action"];
		//[formValues setObject:[NSString stringWithFormat:@"%d", _vo.topic_id] forKey:@"topicID"];
		[formValues setObject:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[formValues setObject:[dateFormat stringFromDate:_lastDate] forKey:@"datetime"];
		
		NSLog(@"LAST DATE:[%@]", [dateFormat stringFromDate:_lastDate]);
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI];
		self.updateListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:YES expiration:[NSDate date]]; // 1 hour expiration for now
	}
}


#pragma mark - View lifecycle
- (void)loadView
{
	[super loadView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date]; // should return date data source was last change	
}


@end
