//
//  SNFollowerInfoView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFollowerInfoView.h"

#import "SNAppDelegate.h"

@implementation SNFollowerInfoView

-(id)initWithFrame:(CGRect)frame followerVO:(SNFollowerVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		[self setBackgroundColor:[UIColor colorWithWhite:0.25 alpha:1.0]];
		
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 35.0, 35.0)];
		_avatarImgView.imageURL = [NSURL URLWithString:_vo.avatar_url];
		_avatarImgView.alpha = 1.0;
		[self addSubview:_avatarImgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 8.0, 150.0, 26.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_nameLabel.textColor = [UIColor whiteColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.text = _vo.follower_name;
		[self addSubview:_nameLabel];
		
		_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 50.0, 150.0, 80.0)];
		_infoLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_infoLabel.textColor = [UIColor whiteColor];
		_infoLabel.backgroundColor = [UIColor clearColor];
		_infoLabel.text = _vo.blurb;
		_infoLabel.numberOfLines = 0;
		[self addSubview:_infoLabel];
		
		_queueButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_queueButton.frame = CGRectMake(4.0, 150.0, 80.0, 24.0);
		[_queueButton setBackgroundImage:[[UIImage imageNamed:@"tagBG_nonActive.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_queueButton setBackgroundImage:[[UIImage imageNamed:@"tagBG_active.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:12.0] forState:UIControlStateHighlighted];
		_queueButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10.0];
		_queueButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_queueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_queueButton.titleLabel.shadowColor = [UIColor blackColor];
		_queueButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		[_queueButton setTitle:@"Queue" forState:UIControlStateNormal];
		[_queueButton addTarget:self action:@selector(_goQueue) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_queueButton];
		
		_watchButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_watchButton.frame = CGRectMake(90.0, 150.0, 80.0, 24.0);
		[_watchButton setBackgroundImage:[[UIImage imageNamed:@"tagBG_nonActive.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_watchButton setBackgroundImage:[[UIImage imageNamed:@"tagBG_active.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:12.0] forState:UIControlStateHighlighted];
		_watchButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10.0];
		_watchButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_watchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_watchButton.titleLabel.shadowColor = [UIColor blackColor];
		_watchButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		[_watchButton setTitle:@"Watch" forState:UIControlStateNormal];
		[_watchButton addTarget:self action:@selector(_goWatch) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_watchButton];
		
	}
	
	return (self);
}

-(void)dealloc {
	[_nameLabel release];
	[_infoLabel release];
	[_avatarImgView release];
	
	[_queueButton release];
	[_watchButton release];
	
	[super dealloc];
}


#pragma mark - Navigation
-(void)_goQueue {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"QUEUE_FOLLOWER" object:_vo];
	[self removeFromSuperview];
}

-(void)_goWatch {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FOLLOWER_ARTICLES" object:_vo];
	[self removeFromSuperview];
}



@end
