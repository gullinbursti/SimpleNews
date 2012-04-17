//
//  SNHeaderView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNHeaderView_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNHeaderView_iPhone

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 53.0)])) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.941 alpha:1.0]];
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 52.0, 320.0, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:lineView];
	}
	
	return (self);
}

-(id)initWithTitle:(NSString *)title {
	if ((self = [self init])) {
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(64.0, 16.0, 192.0, 24)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:18];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.text = title;
		[self addSubview:titleLabel];
	}
	
	return (self);
}

@end
