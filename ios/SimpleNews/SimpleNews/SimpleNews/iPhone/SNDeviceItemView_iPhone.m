//
//  SNDeviceItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNDeviceItemView_iPhone.h"


@implementation SNDeviceItemView_iPhone

@synthesize vo = _vo;

-(id)initWithFrame:(CGRect)frame withVO:(SNDeviceVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		if (_vo.type_id % 2 == 1)
			[self setBackgroundColor:[UIColor blackColor]];
		
		else
			[self setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
		
		UIButton *toggleButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		toggleButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[toggleButton addTarget:self action:@selector(_goToggle) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:toggleButton];
		
		_titleLabel.text = _vo.device_title;
		_checkImageView.hidden = !(_vo.type_id == 1);
	}
	
	return (self);
}



#pragma mark - Button handlers
-(void)_goToggle {
	
	if (_vo.type_id != 4) {
		_checkImageView.hidden = NO;
		[super toggleSelected:YES];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DEVICE_SELECTED" object:_vo];
}


-(void)deselect {
	[super deselect];
	_checkImageView.hidden = YES;
}

@end
