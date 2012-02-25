//
//  SNCategoryItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNCategoryItemView_iPhone.h"

#import "SNAppDelegate.h"

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
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 0, self.frame.size.width, 64)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = _vo.category_title;
		[self addSubview:_titleLabel];
		
		_checkImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(290, 20, 24, 24)] autorelease];
		_checkImageView.image = [UIImage imageNamed:@"checkMark.png"];
		_checkImageView.hidden = !_isSelected;
		[self addSubview:_checkImageView];
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 63.0, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor whiteColor]];
		//[self addSubview:lineView];
	}
	
	return (self);
}


-(void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
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
