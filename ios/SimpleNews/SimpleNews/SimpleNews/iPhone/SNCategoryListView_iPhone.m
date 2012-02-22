//
//  SNCategoryListView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCategoryListView_iPhone.h"

#import "SNCategoryItemView_iPhone.h"


@implementation SNCategoryListView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_allViews = [[NSMutableArray alloc] init];
		_allItemVOs = [[NSMutableArray alloc] init];
		_activeItemVOs = [[NSMutableArray alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_categorySelected:) name:@"CATEGORY_SELECTED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_categoryDeselected:) name:@"CATEGORY_DESELECTED" object:nil];
		
		NSString *testCategoriesPath = [[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testCategoriesPath] options:NSPropertyListImmutable format:nil error:nil];
		
		[self setBackgroundColor:[UIColor blackColor]];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = NO;
		_scrollView.scrollsToTop = YES;
		_scrollView.pagingEnabled = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = YES;
		_scrollView.contentSize = frame.size;
		[self addSubview:_scrollView];
		
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
		
		_scrollView.contentSize = CGSizeMake(frame.size.width, [_allItemVOs count] * 64);
		
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


@end
