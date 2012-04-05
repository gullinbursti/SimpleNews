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
		
		_isSelected = NO;
		
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 0, self.frame.size.width, 64)] autorelease];
		titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16.0];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor blackColor];
		[self addSubview:titleLabel];
		
		_checkImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(284, 20, 24, 24)] autorelease];
		_checkImageView.image = [UIImage imageNamed:@"optionsCheckMark.png"];
		[self addSubview:_checkImageView];
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 69.0, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:lineView];
		
		UIButton *toggleButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		toggleButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		//[toggleButton addTarget:self action:@selector(_goToggle) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:toggleButton];
		
		titleLabel.text = _vo.option_title;
		_checkImageView.hidden = YES;
	}
	
	return (self);
}

-(void)dealloc {
	[_checkImageView release];
	
	[super dealloc];
}


-(void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	_checkImageView.hidden = !_isSelected;
}

-(void)deselect {
	_isSelected = NO;
}


#pragma mark - Button handlers
-(void)_goToggle {
	
	if (_vo.option_id < 4)
		_checkImageView.hidden = !_isSelected;
	
	_isSelected = !_isSelected;
		
	if (_isSelected)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"OPTION_SELECTED" object:_vo];
		
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"OPTION_DESELECTED" object:_vo];
}

@end
