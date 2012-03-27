//
//  SNCategoryViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCategoryViewCell_iPhone.h"
#import "SNFollowerGridItemView_iPhone.h"
@implementation SNCategoryViewCell_iPhone

@synthesize followers = _followers;


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


-(void)setFollowers:(NSMutableArray *)followers {
	_followers = followers;
	
	int tot = 0;
	for (SNFollowerVO *vo in _followers) {
		int row = tot / (int)([_followers count] * 0.5);
		int col = tot % (int)([_followers count] * 0.5);
		
		SNFollowerGridItemView_iPhone *followerItemView = [[[SNFollowerGridItemView_iPhone alloc] initWithFrame:CGRectMake(col * 80.0, row * 80.0, 80.0, 80.0) followerVO:vo] autorelease];
		[_scrollView addSubview:followerItemView];
		tot++;
	}
	
	int pages = round([_followers count] * 0.125);
	_scrollView.contentSize = CGSizeMake(320.0 * pages, 92);
}


-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
