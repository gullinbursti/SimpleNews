//
//  SNLogoView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNLogoView.h"
#import "SNAppDelegate.h"

@implementation SNLogoView

-(id)initAtPosition:(CGPoint)pos {
	if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, 200.0, 100.0)])) {
		UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 56.0, 56.0)];
		[bgView setBackgroundColor:[UIColor blueColor]];
		[self addSubview:bgView];
		
		UILabel *logoCharLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -4, 56, 56)];
		logoCharLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:40.0];
		logoCharLabel.backgroundColor = [UIColor clearColor];
		logoCharLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		logoCharLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		logoCharLabel.textColor = [UIColor blackColor];
		logoCharLabel.textAlignment = UITextAlignmentCenter;
		logoCharLabel.text = @"a";
		[bgView addSubview:logoCharLabel];
		
		UILabel *logoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, 200, 20)];
		logoNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16.0];
		logoNameLabel.backgroundColor = [UIColor clearColor];
		logoNameLabel.textColor = [UIColor whiteColor];
		logoCharLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		logoCharLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		logoNameLabel.text = @"news network";
		[self addSubview:logoNameLabel];
	}
	
	return (self);
}


@end
