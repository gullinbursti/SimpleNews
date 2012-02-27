//
//  SNCategoryItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCategoryItemView_iPhone.h"


@implementation SNCategoryItemView_iPhone

-(id)initWithFrame:(CGRect)frame withVO:(SNCategoryItemVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		
		_isSelected = NO;
		_vo = vo;
		
		if (_vo.category_id % 2 == 1)
			[self setBackgroundColor:[UIColor blackColor]];
		
		else
			[self setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
		
		UIButton *toggleButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		toggleButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[toggleButton addTarget:self action:@selector(_goToggle) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:toggleButton];
		
		_titleLabel.text = _vo.category_title;
		_checkImageView.hidden = !_isSelected;
	}
	
	return (self);
}


-(void)toggleSelected:(BOOL)isSelected {
	[super toggleSelected:isSelected];
	
	_checkImageView.hidden = !_isSelected;
}


#pragma mark - Button handlers
-(void)_goToggle {
	_isSelected = !_isSelected;
	_checkImageView.hidden = !_isSelected;
	
	if (_isSelected)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CATEGORY_SELECTED" object:_vo];
	
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CATEGORY_DESELECTED" object:_vo];
}


@end
