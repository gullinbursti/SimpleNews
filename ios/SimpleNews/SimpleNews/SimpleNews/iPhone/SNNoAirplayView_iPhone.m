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
		UILabel *messageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(82.0, 206.0, 155.0, 24)] autorelease];
		messageLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16.0];
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.textAlignment = UITextAlignmentCenter;
		messageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		messageLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		messageLabel.text = @"connect to AirPlay™";
		[self addSubview:messageLabel];
		
		UIButton *skipButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		skipButton.frame = CGRectMake(128.0, 400.0, 64.0, 32.0);
		[skipButton setBackgroundColor:[UIColor purpleColor]];
		skipButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[skipButton setTitle:@"NEXT" forState:UIControlStateNormal];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:skipButton];
		
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
