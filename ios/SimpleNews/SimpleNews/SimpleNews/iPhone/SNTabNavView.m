//
//  SNTabNavView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.21.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNTabNavView.h"
#import "SNAppDelegate.h"

@implementation SNTabNavView

@synthesize feedButton = _feedButton;
@synthesize popularButton = _popularButton;
@synthesize activityButton = _activityButton;
@synthesize profileButton = _profileButton;
@synthesize composeButton = _composeButton;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor blackColor];
		
		_feedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_feedButton.frame = CGRectMake(0.0, 0.0, 60.0, 48.0);
		[_feedButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_feedButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_feedButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_feedButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_feedButton setTitle:@"Feed" forState:UIControlStateNormal];
		[self addSubview:_feedButton];
		
		_popularButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_popularButton.frame = CGRectMake(60.0, 0.0, 70.0, 48.0);
		[_popularButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_popularButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_popularButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_popularButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_popularButton setTitle:@"Popular" forState:UIControlStateNormal];
		[self addSubview:_popularButton];
		
		_activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_activityButton.frame = CGRectMake(190.0, 0.0, 70.0, 48.0);
		[_activityButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_activityButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_activityButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_activityButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_activityButton setTitle:@"Activity" forState:UIControlStateNormal];
		[self addSubview:_activityButton];
		
		_profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_profileButton.frame = CGRectMake(260.0, 0.0, 60.0, 48.0);
		[_profileButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_profileButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_profileButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_profileButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_profileButton setTitle:@"Profile" forState:UIControlStateNormal];
		[self addSubview:_profileButton];
		
		_composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_composeButton.frame = CGRectMake(130.0, 0.0, 60.0, 48.0);
		[_composeButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_composeButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_composeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_composeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[self addSubview:_composeButton];
	}
	
	return (self);
}


@end
