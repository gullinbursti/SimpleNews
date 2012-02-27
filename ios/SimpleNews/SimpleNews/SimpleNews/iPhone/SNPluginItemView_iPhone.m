//
//  SNPluginItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNPluginItemView_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNPluginItemView_iPhone

-(id)initWithFrame:(CGRect)frame withVO:(SNPluginVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		
		_isSelected = NO;
		_vo = vo;
		
		if (_vo.plugin_id % 2 == 0)
			[self setBackgroundColor:[UIColor blackColor]];
		
		else
			[self setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
		
		UIButton *toggleButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		toggleButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[toggleButton addTarget:self action:@selector(_goToggle) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:toggleButton];
		
		_titleLabel.text = _vo.plugin_title;
		_checkImageView.hidden = YES;
		
		UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 0.0, 83.0, 64.0)];
		priceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16.0];
		priceLabel.backgroundColor = [UIColor clearColor];
		priceLabel.textColor = [UIColor colorWithWhite:0.266 alpha:1.0];
		priceLabel.textAlignment = UITextAlignmentRight;
		priceLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		priceLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		priceLabel.text = _vo.price;
		[self addSubview:priceLabel];
	}
	
	return (self);
}


-(void)toggleSelected:(BOOL)isSelected {
	[super toggleSelected:isSelected];
}


#pragma mark - Button handlers
-(void)_goToggle {
	_isSelected = !_isSelected;
	
	if (_isSelected)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"PLUGIN_SELECTED" object:_vo];
}

@end
