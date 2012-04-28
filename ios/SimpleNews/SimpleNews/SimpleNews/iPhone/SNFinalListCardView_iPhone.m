//
//  SNFinalListCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFinalListCardView_iPhone.h"
#import "SNListVO.h"
#import "SNListItemViewCell_iPhone.h"

@implementation SNFinalListCardView_iPhone

-(id)initWithFrame:(CGRect)frame addlLists:(NSMutableArray *)lists {
	if ((self = [super initWithFrame:frame])) {
		_lists = lists;
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.rowHeight = 62.0;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.scrollsToTop = NO;
		_tableView.showsVerticalScrollIndicator = NO;
		[_holderView addSubview:_tableView];
		
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		_refreshHeaderView.delegate = self;
		[_tableView addSubview:_refreshHeaderView];
		[_refreshHeaderView refreshLastUpdatedDate];
	}
	
	return (self);
}

- (void)reloadTableViewDataSource {
	_reloading = YES;	
}

- (void)doneLoadingTableViewData {
	_reloading = NO;
	
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}


#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date]; // should return date data source was last change	
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
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

#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_lists count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNListItemViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNListItemViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNListItemViewCell_iPhone alloc] init];
	
	cell.listVO = (SNListVO *)[_lists objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;	
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (62.0);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	SNListVO *vo = (SNListVO *)[_lists objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_ARTICLES" object:vo];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE2" object:vo.handle];
}

@end
