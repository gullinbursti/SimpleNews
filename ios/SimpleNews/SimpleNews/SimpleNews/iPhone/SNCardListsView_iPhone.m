//
//  SNCardListsView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCardListsView_iPhone.h"
#import "SNAppDelegate.h"
#import "SNListVO.h"
#import "SNListCardView_iPhone.h"
#import "SNArticleListViewController_iPhone.h"

#import "EGOImageLoader.h"

#import "SNFinalListCardView_iPhone.h"
#import "SNWebPageViewController_iPhone.h"

@implementation SNCardListsView_iPhone

-(id)initWithLists:(NSArray *)unsortedLists {
	if ((self = [super initWithFrame:CGRectMake(270.0, 0.0, 320.0, 438.0)])) {
		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSArray *parsedLists = [unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		NSMutableArray *list = [NSMutableArray array];
		for (NSDictionary *serverList in parsedLists) {
			SNListVO *vo = [SNListVO listWithDictionary:serverList];
			NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
			
			if (vo != nil)
				[list addObject:vo];
		}
		
		_lists = [list copy];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = YES;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		[self addSubview:_scrollView];
		
		NSMutableArray *finalList = [NSMutableArray new];
		
		int cnt = 0;
		for (SNListVO *vo in _lists) {
			if (cnt < 3) {
				SNListCardView_iPhone *listCardView = [[SNListCardView_iPhone alloc] initWithFrame:CGRectMake(cnt * self.frame.size.width, 0.0, self.frame.size.width, self.frame.size.height) listVO:vo];
				[_scrollView addSubview:listCardView];
				cnt++;
				
			} else {
				[finalList addObject:vo];
			}
		}
		
		SNFinalListCardView_iPhone *finalListCardView = [[SNFinalListCardView_iPhone alloc] initWithFrame:CGRectMake(cnt * self.frame.size.width, 0.0, self.frame.size.width, self.frame.size.height) addlLists:finalList];
		[_scrollView addSubview:finalListCardView];
		
		_scrollView.contentSize = CGSizeMake((cnt + 1) * self.frame.size.width, self.frame.size.height);
		
		
		_paginationView = [[SNPaginationView alloc] initWithTotal:4 coords:CGPointMake(160.0, 460.0)];
		[self addSubview:_paginationView];

	}
	
	return (self);
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_paginationView updToPage:round(scrollView.contentOffset.x / self.frame.size.width)];
}


@end
