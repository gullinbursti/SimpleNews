//
//  SNNoAirplayView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.29.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNNoAirplayView_iPhone.h"

#import "SNAppDelegate.h"

#import <MediaPlayer/MediaPlayer.h>

@implementation SNNoAirplayView_iPhone

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)])) {
		_messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.0, 206.0, 155.0, 24)];
		_messageLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16.0];
		_messageLabel.backgroundColor = [UIColor clearColor];
		_messageLabel.textColor = [UIColor whiteColor];
		_messageLabel.textAlignment = UITextAlignmentCenter;
		_messageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_messageLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_messageLabel.text = @"connect to AirPlay™";
		[self addSubview:_messageLabel];
		
		_skipButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_skipButton.frame = CGRectMake(128.0, 400.0, 64.0, 32.0);
		[_skipButton setBackgroundColor:[UIColor purpleColor]];
		_skipButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_skipButton setTitle:@"NEXT" forState:UIControlStateNormal];
		[_skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_skipButton];
		
		MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:CGRectMake(140.0, 300.0, 40.0, 20.0)] autorelease];
		[volumeView setShowsVolumeSlider:NO];
		[volumeView sizeToFit];
		[self addSubview:volumeView];
	}
	
	return (self);
}


-(void)_goSkip {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INTRO_COMPLETE" object:nil];
}


@end
