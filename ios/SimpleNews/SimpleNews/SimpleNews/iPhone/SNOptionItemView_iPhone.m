//
//  SNOptionItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNOptionItemView_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNOptionItemView_iPhone

-(id)initWithFrame:(CGRect)frame withVO:(SNOptionVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		
		_isSelected = NO;
		_vo = vo;
		
		if (_vo.option_id % 2 == 0)
			[self setBackgroundColor:[UIColor colorWithWhite:0.145 alpha:1.0]];
		
		else
			[self setBackgroundColor:[UIColor colorWithWhite:0.133 alpha:1.0]];
		
		UIButton *toggleButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		toggleButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[toggleButton addTarget:self action:@selector(_goToggle) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:toggleButton];
		
		_titleLabel.text = _vo.option_title;
		_checkImageView.hidden = YES;
	}
	
	return (self);
}


-(void)toggleSelected:(BOOL)isSelected {
	[super toggleSelected:isSelected];
}


#pragma mark - Button handlers
-(void)_goToggle {
	_isSelected = !_isSelected;
	_checkImageView.hidden = !_isSelected;
	
	if (_isSelected)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"OPTION_SELECTED" object:_vo];
}

@end
