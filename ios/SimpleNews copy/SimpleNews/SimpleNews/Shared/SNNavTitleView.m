//
//  SNNavTitleView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNNavTitleView.h"

#import "SNAppDelegate.h"

@implementation SNNavTitleView

-(id)initWithTitle:(NSString *)title {
	if ((self = [super init])) {
		UIFont *font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18.0];
		CGSize textSize = [title sizeWithFont:font constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(-textSize.width * 0.5, (-textSize.height * 0.5) + 4.0, textSize.width, textSize.height)];
		[_label setFont:font];
		_label.backgroundColor = [UIColor clearColor];
		_label.textColor = [UIColor whiteColor];
		//_label.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.33];
		//_label.shadowOffset = CGSizeMake(1.0, 1.0);
		[_label setText:title];
		[self addSubview:_label];
	}
	
	return (self);
}
@end
