//
//  SNComposePopOverView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.18.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNComposePopOverView_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNComposePopOverView_iPhone

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
		
		_cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_cameraButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
		_cameraButton.frame = CGRectMake(10.0, 10.0, 100.0, 48.0);
		[_cameraButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_cameraButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_cameraButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_cameraButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_cameraButton setTitle:@"Camera" forState:UIControlStateNormal];
		[self addSubview:_cameraButton];
		
		_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		_cameraRollButton.frame = CGRectMake(100.0, 10.0, 100.0, 48.0);
		[_cameraRollButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_cameraRollButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_cameraRollButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_cameraRollButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_cameraRollButton setTitle:@"Camera Roll" forState:UIControlStateNormal];
		[self addSubview:_cameraRollButton];
		
		_fbFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_fbFriendsButton addTarget:self action:@selector(_goFBFriends) forControlEvents:UIControlEventTouchUpInside];
		_fbFriendsButton.frame = CGRectMake(190.0, 10.0, 100.0, 48.0);
		[_fbFriendsButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_fbFriendsButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_fbFriendsButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_fbFriendsButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_fbFriendsButton setTitle:@"FB Friends" forState:UIControlStateNormal];
		[self addSubview:_fbFriendsButton];	
	}
	
	return (self);
}

#pragma mark - Navigtion
- (void)_goCamera {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
}

- (void)_goCameraRoll {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA_ROLL" object:nil];
}

- (void)_goFBFriends {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_FRIENDS" object:nil];
}


@end
