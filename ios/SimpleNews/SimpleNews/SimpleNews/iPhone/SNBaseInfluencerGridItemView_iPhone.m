//
//  SNBaseInfluencerGridItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNBaseInfluencerGridItemView_iPhone.h"

@implementation SNBaseInfluencerGridItemView_iPhone

@synthesize vo = _vo;

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isSelected = NO;
		_vo = nil;
		
		_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		_holderView.clipsToBounds = YES;
		[self addSubview:_holderView];
	}
	
	return (self);
}

-(void)dealloc {
	[_holderView release];
	
	[super dealloc];
}

-(void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	
	/*
	if (_isSelected)
		[self fadeTo:1.0];
	
	else
		[self fadeTo:0.33];
	*/
}

-(void)fadeTo:(float)opac {
	[UIView animateWithDuration:0.15 animations:^(void) {
		_holderView.alpha = opac;
	}];
}

@end
