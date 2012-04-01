//
//  SNCategoryViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCategoryViewCell_iPhone.h"
#import "SNInfluencerGridItemView_iPhone.h"
@implementation SNCategoryViewCell_iPhone

@synthesize influencers = _influencers;


+(NSString *)cellReuseIdentifier {
	return @"CategoryViewCell";
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		self.bounds = CGRectMake(0.0, 0.0, 320.0, 170.0);
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		_scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 4.0, 320.0, 170.0)] autorelease];
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.pagingEnabled = YES;
		[self addSubview:_scrollView];
	}
	
	return (self);
}


-(void)setInfluencers:(NSMutableArray *)influencers {
	_influencers = influencers;
	
	int tot = 0;
	int row = 0;
	int col = -1;
	for (SNInfluencerVO *vo in _influencers) {
		//row = tot / (int)([_influencers count] * 0.5);
		//col = tot % (int)([_influencers count] * 0.5);
		
		row = tot % 2;
		if (tot % 2 == 0) {
			col++;
		}
		
		
		NSLog(@"Influencers \"@%@\" (%d, %d) -- [%d]", vo.handle, row, col, tot);
		
		SNInfluencerGridItemView_iPhone *influencerItemView = [[[SNInfluencerGridItemView_iPhone alloc] initWithFrame:CGRectMake(col * 80.0, row * 80.0, 80.0, 80.0) influencerVO:vo] autorelease];
		[_scrollView addSubview:influencerItemView];
		tot++;
	}
	
	int pages = round([_influencers count] * 0.125);
	_scrollView.contentSize = CGSizeMake(320.0 * pages, 92);
}


-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
