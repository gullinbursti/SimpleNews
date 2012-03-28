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
		UILabel *messageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(82.0, 206.0, 155.0, 24)] autorelease];
		messageLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16.0];
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.textAlignment = UITextAlignmentCenter;
		messageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		messageLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		messageLabel.text = @"No Wi-Fi connection!";
		[self addSubview:messageLabel];		
	}
	
	return (self);
}

@end
