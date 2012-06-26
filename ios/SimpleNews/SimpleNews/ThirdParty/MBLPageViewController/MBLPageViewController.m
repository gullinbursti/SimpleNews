//
//  MBLPageViewController.m
//  MBLAssetLoader
//
//  Created by Jesse Boley on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MBLPageViewController.h"

@interface MBLPageViewController () <UIScrollViewDelegate>
{
	MBLPageItemViewController *_previousView;
	MBLPageItemViewController *_centerView;
	MBLPageItemViewController *_nextView;
	NSInteger _currentPage;
	
	BOOL _shouldAnimateDragOffset;
	BOOL _isHandlingDrag;
	NSInteger _dragStartPage;
	CGFloat _dragStartOffset;
}
@property(strong, nonatomic) NSArray *items;
@property(nonatomic, readwrite) NSUInteger selectedIndex;
@end

@implementation MBLPageViewController

@synthesize delegate = _delegate;
@synthesize items = _items;
@synthesize selectedIndex = _selectedIndex;
@synthesize scrollView = _scrollView;

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	CGRect bounds = self.view.bounds;
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, bounds.size.width, bounds.size.height - 44.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//_scrollView.opaque = NO;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];

	_centerView = [_delegate makeItemViewControllerForPageViewController:self];
	[_scrollView addSubview:_centerView.view];
	_previousView = [_delegate makeItemViewControllerForPageViewController:self];
	_nextView = [_delegate makeItemViewControllerForPageViewController:self];
	
	[self configureView:NO];
}

- (void)configureWithSelectedIndex:(NSUInteger)index fromItems:(NSArray *)allItems
{
	self.selectedIndex = index;
	self.items = allItems;
	
	[self configureView:NO];
}

- (void)_adjustItemPositions:(BOOL)updateOffset
{
	CGRect scrollBounds = CGRectMake(0.0, 0.0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
	_currentPage = 0;
	
	if (_previousView.view.superview != nil) {
		_previousView.view.frame = scrollBounds;
		scrollBounds.origin.x += scrollBounds.size.width;
		_currentPage = 1;
	}
	
	_centerView.view.frame = scrollBounds;
	scrollBounds.origin.x += scrollBounds.size.width;
	
	if (_nextView.view.superview != nil) {
		_nextView.view.frame = scrollBounds;
		scrollBounds.origin.x += scrollBounds.size.width;
	}
	
	if (updateOffset) {
		_scrollView.contentSize = CGSizeMake(scrollBounds.origin.x, scrollBounds.size.height);
		_scrollView.contentOffset = CGPointMake(_centerView.view.frame.origin.x, 0.0);
	}
}

- (void)configureView:(BOOL)animated
{	
	if ([_items count] > 0) {
		_centerView.item = [_items objectAtIndex:_selectedIndex];
		[_centerView updateAnimationWithPercent:1.0 appearing:YES];
		[_centerView pageItemViewDidBecomeFocusAnimated:animated];
		
		if (_selectedIndex > 0) {
			[_scrollView addSubview:_previousView.view];
			_previousView.item = [_items objectAtIndex:(_selectedIndex - 1)];
			[_previousView updateAnimationWithPercent:1.0 appearing:NO];
			[_previousView pageItemViewWasPlacedOffscreen];
		}
		else {
			[_previousView.view removeFromSuperview];
		}
		
		if (_selectedIndex < ([_items count] - 1)) {
			[_scrollView addSubview:_nextView.view];
			_nextView.item = [_items objectAtIndex:(_selectedIndex + 1)];
			[_nextView updateAnimationWithPercent:1.0 appearing:NO];
			[_nextView pageItemViewWasPlacedOffscreen];
		}
		else {
			[_nextView.view removeFromSuperview];
		}
		
		[self _adjustItemPositions:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self _adjustItemPositions:YES];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self configureView:NO];
}

- (void)_updateMasterSelection
{
	[_delegate pageViewController:self selectionDidChangeToIndex:_selectedIndex];
}

- (void)_shiftToPrevious
{
	// Shifts all views to the left
	MBLPageItemViewController *newPrevious = _nextView;
	_nextView = _centerView;
	_centerView = _previousView;
	_previousView = newPrevious;
	
	if (_selectedIndex > 0) {
		_previousView.item = [_items objectAtIndex:_selectedIndex - 1];
	
		// We need to position the previous view directly since we may be in the middle of scrolling
		CGRect previousFrame = _centerView.view.frame;
		previousFrame.origin.x -= previousFrame.size.width;
		_previousView.view.frame = previousFrame;
		[_previousView pageItemViewWasPlacedOffscreen];
	}
	else {
		[_previousView.view removeFromSuperview];
	}
}

- (void)_shiftToNext
{
	// Shifts all views to the right
	MBLPageItemViewController *newNext = _previousView;
	_previousView = _centerView;
	_centerView = _nextView;
	_nextView = newNext;
	
	if (_selectedIndex < [_items count] - 1) {
		_nextView.item = [_items objectAtIndex:_selectedIndex + 1];
		
		// We need to position the previous view directly since we may be in the middle of scrolling
		CGRect nextFrame = _centerView.view.frame;
		nextFrame.origin.x += nextFrame.size.width;
		_nextView.view.frame = nextFrame;
		[_nextView pageItemViewWasPlacedOffscreen];
	}
	else {
		[_nextView.view removeFromSuperview];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (_isHandlingDrag) {
		// User is beginning another drag before we finished processing the old one so
		// we need to make sure we update our page positions now
		[self _dragDidFinish];
	}
	
	_dragStartPage = _currentPage;
	_dragStartOffset = _scrollView.contentOffset.x;
	_shouldAnimateDragOffset = YES;
	_isHandlingDrag = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_shouldAnimateDragOffset) {
		CGFloat distance =  _dragStartOffset - _scrollView.contentOffset.x;
		CGFloat percentComplete = fabsf(distance) / _scrollView.bounds.size.width;

		//NSLog(@"percent: %f, distance: %f", percentComplete, distance);
		
		// Center view is always disappearing
		[_centerView updateAnimationWithPercent:percentComplete appearing:NO];

		// Direction tells us whether the user moved towards the next or previous view.
		if (distance < 0)
			[_nextView updateAnimationWithPercent:percentComplete appearing:YES];
		else
			[_previousView updateAnimationWithPercent:percentComplete appearing:YES];
	}
}

- (void)_dragDidFinish
{
	NSLog(@"update");
	
	_shouldAnimateDragOffset = NO;
	_isHandlingDrag = NO;
	
	NSInteger page = floor(_scrollView.contentOffset.x / _scrollView.bounds.size.width + 0.5f);
	NSUInteger newIndex = _selectedIndex + (page - _currentPage);
	NSLog(@"new index: %u", newIndex);
	
	if (newIndex != _selectedIndex) {
		if (newIndex < _selectedIndex) {
			_selectedIndex--;
			_currentPage--;
			[self _updateMasterSelection];
			//if (_selectedIndex > 0)
				[self _shiftToPrevious];
		}
		else if (newIndex > _selectedIndex) {
			_selectedIndex++;
			_currentPage++;
			[self _updateMasterSelection];
			//if (_selectedIndex < [_items count] - 1)
				[self _shiftToNext];
		}
	}
	
	[self configureView:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
		[self _dragDidFinish];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self _dragDidFinish];
}

@end
