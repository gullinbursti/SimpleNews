//
//  SNShareSheetView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNShareSheetView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNShareSheetView_iPhone

@synthesize vo = _vo;

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 339.0)] autorelease];
		bgImgView.image = [UIImage imageNamed:@"shareBG.png"];
		[self addSubview:bgImgView];
		
		UIButton *facebookButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		facebookButton.frame = CGRectMake(38.0, 38.0, 244.0, 64.0);
		[facebookButton setBackgroundImage:[[UIImage imageNamed:@"shareButtons_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[facebookButton setBackgroundImage:[[UIImage imageNamed:@"shareButtons_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		facebookButton.titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14.0];
		facebookButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		facebookButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		facebookButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
		[facebookButton addTarget:self action:@selector(_goFacebook) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:facebookButton];
		
		UIButton *twitterButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		twitterButton.frame = CGRectMake(38.0, 112.0, 244.0, 64.0);
		[twitterButton setBackgroundImage:[[UIImage imageNamed:@"shareButtons_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[twitterButton setBackgroundImage:[[UIImage imageNamed:@"shareButtons_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		twitterButton.titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14.0];
		twitterButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[twitterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		twitterButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		twitterButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
		[twitterButton addTarget:self action:@selector(_goTwitter) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:twitterButton];
		
		UIButton *emailButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		emailButton.frame = CGRectMake(38.0, 186.0, 244.0, 64.0);
		[emailButton setBackgroundImage:[[UIImage imageNamed:@"shareButtons_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[emailButton setBackgroundImage:[[UIImage imageNamed:@"shareButtons_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		emailButton.titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14.0];
		emailButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[emailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		emailButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		emailButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[emailButton setTitle:@"Email" forState:UIControlStateNormal];
		[emailButton addTarget:self action:@selector(_goEmail) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:emailButton];
		
		UIButton *cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		cancelButton.frame = CGRectMake(38.0, 260.0, 244.0, 64.0);
		[cancelButton setBackgroundImage:[[UIImage imageNamed:@"shareCancelButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[[UIImage imageNamed:@"shareCancelButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		cancelButton.titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14.0];
		cancelButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		cancelButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		cancelButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
		[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cancelButton];
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];
}

-(void)setVo:(SNArticleVO *)vo {
	_vo = vo;
}


#pragma mark - Navigation
-(void)_goFacebook {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FACEBOOK_SHARE" object:_vo];
}

-(void)_goTwitter {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TWITTER_SHARE" object:_vo];
}

-(void)_goEmail {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EMAIL_SHARE" object:_vo];
}

-(void)_goCancel {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CANCEL_SHARE" object:_vo];
}

@end
