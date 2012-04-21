//
//  SNBaseListCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNBaseListCardView_iPhone.h"

@implementation SNBaseListCardView_iPhone

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_holderView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 12.0, 295.0, 450.0)];
		[_holderView setBackgroundColor:[UIColor whiteColor]];
		_holderView.layer.cornerRadius = 8.0;
		_holderView.clipsToBounds = YES;
		_holderView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_holderView.layer.borderWidth = 1.0;
		[self addSubview:_holderView];
	}
	
	return (self);
}


@end
