//
//  SNBaseListItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNBaseListItemView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNBaseListItemView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isSelected = NO;
		
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 0, self.frame.size.width, 64)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[self addSubview:_titleLabel];
		
		_checkImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(290, 20, 24, 24)] autorelease];
		_checkImageView.image = [UIImage imageNamed:@"checkMark.png"];
		[self addSubview:_checkImageView];
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 63.0, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor whiteColor]];
		//[self addSubview:lineView];
	}
	
	return (self);
}


-(void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
}

-(void)deselect {
	_isSelected = NO;
}


@end
