//
//  SNNoWifiView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.05.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNNoWifiView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNNoWifiView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.0, 206.0, 155.0, 24)];
		_messageLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16.0];
		_messageLabel.backgroundColor = [UIColor clearColor];
		_messageLabel.textColor = [UIColor whiteColor];
		_messageLabel.textAlignment = UITextAlignmentCenter;
		_messageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_messageLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_messageLabel.text = @"No Wi-Fi connection!";
		[self addSubview:_messageLabel];		
	}
	
	return (self);
}

@end
