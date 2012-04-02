//
//  SNListItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNListItemView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNListItemView_iPhone

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 20.0)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		titleLabel.text = _vo.list_name;
		[self addSubview:titleLabel];
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];	
}

@end
