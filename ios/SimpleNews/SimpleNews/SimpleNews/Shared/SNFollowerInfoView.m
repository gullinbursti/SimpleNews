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
		
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_bgImgView.image = [UIImage imageNamed:@"infoOverlay.png"];
		[self addSubview:_bgImgView];
		
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 37.0, 37.0)];
		_avatarImgView.imageURL = [NSURL URLWithString:_vo.avatar_url];
		_avatarImgView.alpha = 1.0;
		[self addSubview:_avatarImgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 22.0, 150.0, 26.0)];
		_nameLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		_nameLabel.textColor = [UIColor whiteColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.text = _vo.follower_name;
		[self addSubview:_nameLabel];
		
		NSString *total = @"";
		
		if (_vo.totalArticles == 1)
			total = @"%d story assembled";
		
		else
			total = @"%d stories assembled";
		
		_totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 55.0, 150.0, 26.0)];
		_totalLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		_totalLabel.textColor = [UIColor whiteColor];
		_totalLabel.backgroundColor = [UIColor clearColor];
		_totalLabel.text = [NSString stringWithFormat:total, _vo.totalArticles];
		[self addSubview:_totalLabel];
		
		_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 80.0, 150.0, 50.0)];
		_infoLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:12];
		_infoLabel.textColor = [UIColor colorWithWhite:0.816 alpha:1.0];
		_infoLabel.backgroundColor = [UIColor clearColor];
		_infoLabel.text = _vo.blurb;
		_infoLabel.numberOfLines = 0;
		[self addSubview:_infoLabel];
		
		_queueButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_queueButton.frame = CGRectMake(10.0, 150.0, 84.0, 34.0);
		[_queueButton setBackgroundImage:[[UIImage imageNamed:@"followerInfoButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_queueButton setBackgroundImage:[[UIImage imageNamed:@"followerInfoButton_active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		_queueButton.titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:13.0];
		_queueButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_queueButton setTitleColor:[UIColor colorWithWhite:0.773 alpha:1.0] forState:UIControlStateNormal];
		_queueButton.titleLabel.shadowColor = [UIColor blackColor];
		_queueButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		[_queueButton setTitle:@"Queue" forState:UIControlStateNormal];
		[_queueButton addTarget:self action:@selector(_goQueue) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_queueButton];
		
		_watchButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_watchButton.frame = CGRectMake(100.0, 150.0, 84.0, 34.0);
		[_watchButton setBackgroundImage:[[UIImage imageNamed:@"followerInfoButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_watchButton setBackgroundImage:[[UIImage imageNamed:@"followerInfoButton_active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		_watchButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
		_watchButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_watchButton setTitleColor:[UIColor colorWithWhite:0.773 alpha:1.0] forState:UIControlStateNormal];
		_watchButton.titleLabel.shadowColor = [UIColor blackColor];
		_watchButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		[_watchButton setTitle:@"Watch Now" forState:UIControlStateNormal];
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
