//
//  SNCategoryListView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCategoryListView_iPhone.h"

#import "SNCategoryItemView_iPhone.h"

#import "SNPluginVO.h"
#import "SNPluginItemView_iPhone.h"


@implementation SNCategoryListView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_allViews = [[NSMutableArray alloc] init];
		_allItemVOs = [[NSMutableArray alloc] init];
		_activeItemVOs = [[NSMutableArray alloc] init];
		
		_pluginViews = [[NSMutableArray alloc] init];
		_pluginVOs = [[NSMutableArray alloc] init];
		
		_isSearching = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_categorySelected:) name:@"CATEGORY_SELECTED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_categoryDeselected:) name:@"CATEGORY_DESELECTED" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cancelReset:) name:@"CANCEL_RESET" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchEntered:) name:@"SEARCH_ENTERED" object:nil];
		
		NSString *testCategoriesPath = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testCategoriesPath] options:NSPropertyListImmutable format:nil error:nil];
		
		[self setBackgroundColor:[UIColor blackColor]];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = NO;
		_scrollView.scrollsToTop = YES;
		_scrollView.pagingEnabled = NO;
		_scrollView.delegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = YES;
		_scrollView.contentInset = UIEdgeInsetsMake(55.0, 0.0f, 0.0f, 0.0f);
		_scrollView.contentOffset = CGPointMake(0.0, 0.0);
		_scrollView.contentSize = frame.size;
		[self addSubview:_scrollView];
		
		_videoSearchView = [[SNVideoSearchView_iPhone alloc] initWithFrame:CGRectMake(0.0, -55.0, self.frame.size.width, 55.0)];
		[self addSubview:_videoSearchView];
		
		int cnt = 0;
		for (NSDictionary *testCategory in plist) {
			SNCategoryItemVO *vo = [SNCategoryItemVO categoryItemWithDictionary:testCategory];
			SNCategoryItemView_iPhone *itemView = [[[SNCategoryItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, cnt * 64, frame.size.width, 64) withVO:vo] autorelease];
			
			if (cnt == 0) {
				[itemView toggleSelected:YES];
				[_activeItemVOs addObject:vo];
			}
			
			[_allViews addObject:itemView];
			[_allItemVOs addObject:vo];
			[_scrollView addSubview:itemView];
			cnt++;
		}
				
		_scrollView.contentSize = CGSizeMake(frame.size.width, cnt * 64);
		
		UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
		[panRecognizer setMinimumNumberOfTouches:1];
		[panRecognizer setMaximumNumberOfTouches:1];
		[panRecognizer setDelegate:self];
		[self addGestureRecognizer:panRecognizer];
	}
	
	return (self);
}


#pragma mark - Button handlers
-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
	
	if (translatedPoint.x > 10 && abs(translatedPoint.y) < 10.0) {
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_videoSearchView.frame = CGRectMake(0.0, -55.0, _videoSearchView.frame.size.width, _videoSearchView.frame.size.height);
			_scrollView.contentOffset = CGPointMake(0.0, 0.0);
		}];
		 
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CATEGORY_SWIPED" object:nil];
	}
}


#pragma mark - Notification handers
-(void)_categorySelected:(NSNotification *)notification {
	SNCategoryItemVO *vo = (SNCategoryItemVO *)[notification object];
	[_activeItemVOs addObject:vo];
	
	if (vo.category_id == 1) {
		for (int i=1; i<[_allViews count]; i++) {
			SNCategoryItemView_iPhone *itemView = (SNCategoryItemView_iPhone *)[_allViews objectAtIndex:i];
			[itemView toggleSelected:NO];
		}
	
	} else {
		SNCategoryItemView_iPhone *itemView = (SNCategoryItemView_iPhone *)[_allViews objectAtIndex:0];
		[itemView toggleSelected:NO];
	}
}

-(void)_categoryDeselected:(NSNotification *)notification {
	[_activeItemVOs removeObject:(SNCategoryItemVO *)[notification object]];
}



-(void)_cancelReset:(NSNotification *)notificiation {
	NSLog(@"CANCEL");
	
	_isSearching = YES;
}


-(void)_searchEntered:(NSNotification *)notification {
	_isSearching = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_videoSearchView.frame = CGRectMake(0.0, -55.0, _videoSearchView.frame.size.width, _videoSearchView.frame.size.height);
		_scrollView.contentOffset = CGPointMake(0.0, 0.0);
	
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CATEGORY_SWIPED" object:nil];
	}];
	
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//_iphoneVideoView.frame = CGRectMake(0.0, -scrollView.contentOffset.y, scrollView.bounds.size.width, 150.0);
	//CGRect frame = _activeListViewController.view.frame;
	
	NSLog(@"%f]", scrollView.contentOffset.y);
	
	if (_scrollView.contentOffset.y > -55 && _scrollView.contentOffset.y < 0)
		_videoSearchView.frame = CGRectMake(0.0, -_scrollView.contentOffset.y - 55, self.frame.size.width, 55.0);
	
	if (_scrollView.contentOffset.y < -55)
		_videoSearchView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 55.0);
	
	if (_scrollView.contentOffset.y > 0)
		_videoSearchView.frame = CGRectMake(0.0, -55.0, self.frame.size.width, 55.0);
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

@end
