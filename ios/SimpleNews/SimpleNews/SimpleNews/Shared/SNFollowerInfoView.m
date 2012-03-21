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
		
		_bgView = [[[UIView alloc] initWithFrame:frame] autorelease];
		[_bgView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
		[self addSubview:_bgView];
		
		UIView *holderView = [[[UIView alloc] initWithFrame:CGRectMake(40.0, 166.0, 244.0, 214.0)] autorelease];
		[self addSubview:holderView];
		
		UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 244.0, 214.0)] autorelease];
		bgImgView.image = [UIImage imageNamed:@"infoOverlay.png"];
		[holderView addSubview:bgImgView];
		
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(15.0, 15.0, 38.0, 38.0)];
		_avatarImgView.imageURL = [NSURL URLWithString:_vo.avatar_url];
		_avatarImgView.alpha = 1.0;
		[holderView addSubview:_avatarImgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 20.0, 214.0, 26.0)];
		_nameLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14];
		_nameLabel.textColor = [UIColor whiteColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_nameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_nameLabel.text = _vo.follower_name;
		[holderView addSubview:_nameLabel];
		
		NSString *total = @"";
		
		if (_vo.totalArticles == 1)
			total = @"%d story assembled";
		
		else
			total = @"%d stories assembled";
		
		_totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 68.0, 214.0, 26.0)];
		_totalLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		_totalLabel.textColor = [UIColor whiteColor];
		_totalLabel.backgroundColor = [UIColor clearColor];
		_totalLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_totalLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_totalLabel.text = [NSString stringWithFormat:total, _vo.totalArticles];
		[holderView addSubview:_totalLabel];
		
		CGSize infoSize = [_vo.blurb sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(214.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 100.0, 214.0, MIN(infoSize.height, 50.0))];
		_infoLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:12];
		_infoLabel.textColor = [UIColor colorWithWhite:0.816 alpha:1.0];
		_infoLabel.backgroundColor = [UIColor clearColor];
		_infoLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_infoLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_infoLabel.text = _vo.blurb;
		_infoLabel.numberOfLines = 0;
		[holderView addSubview:_infoLabel];
		
		_queueButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_queueButton.frame = CGRectMake(15.0, 165.0, 96.0, 34.0);
		[_queueButton setBackgroundImage:[[UIImage imageNamed:@"followerInfoButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_queueButton setBackgroundImage:[[UIImage imageNamed:@"followerInfoButton_active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		_queueButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
		_queueButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_queueButton setTitleColor:[UIColor colorWithWhite:0.773 alpha:1.0] forState:UIControlStateNormal];
		_queueButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_queueButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[_queueButton setTitle:@"Queue" forState:UIControlStateNormal];
		[_queueButton addTarget:self action:@selector(_goQueue) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:_queueButton];
		
		_watchButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_watchButton.frame = CGRectMake(130.0, 165.0, 96.0, 34.0);
		[_watchButton setBackgroundImage:[[UIImage imageNamed:@"followerInfoButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_watchButton setBackgroundImage:[[UIImage imageNamed:@"followerInfoButton_active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		_watchButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
		_watchButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_watchButton setTitleColor:[UIColor colorWithWhite:0.773 alpha:1.0] forState:UIControlStateNormal];
		_watchButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_watchButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[_watchButton setTitle:@"Watch Now" forState:UIControlStateNormal];
		[_watchButton addTarget:self action:@selector(_goWatch) forControlEvents:UIControlEventTouchUpInside];
		[holderView addSubview:_watchButton];
		
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



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == _bgView) {
		NSLog(@"CLOSE");		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FOLLOWER_CLOSED" object:_vo];
		[self removeFromSuperview];
		
		return;
	}
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
