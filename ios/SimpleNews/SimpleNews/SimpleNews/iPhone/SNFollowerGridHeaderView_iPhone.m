//
//  SNFollowerGridHeaderView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFollowerGridHeaderView_iPhone.h"
#import "SNAppDelegate.h"

@interface SNFollowerGridHeaderView_iPhone()
-(void)_goArticles;
-(void)_goOptions;
@end

@implementation SNFollowerGridHeaderView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		UIImageView *titleImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(110.0, 21.0, 94.0, 14.0)] autorelease];
		titleImgView.image = [UIImage imageNamed:@"titlePeople.png"];
		[self addSubview:titleImgView];
		
		_optionsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_optionsButton.frame = CGRectMake(12.0, 12.0, 44.0, 34.0);
		[_optionsButton setBackgroundImage:[[UIImage imageNamed:@"options_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_optionsButton setBackgroundImage:[[UIImage imageNamed:@"options_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[_optionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_optionsButton];
		
		_backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_backButton.frame = CGRectMake(250.0, 12.0, 64.0, 34.0);
		[_backButton setBackgroundImage:[[UIImage imageNamed:@"doneButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_backButton setBackgroundImage:[[UIImage imageNamed:@"doneButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		_backButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		_backButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_backButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_backButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[_backButton setTitle:@"Done" forState:UIControlStateNormal];
		[_backButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_backButton];
	}
	
	return (self);
}

-(void)dealloc {	
	[super dealloc];
}

#pragma mark - Navigation
-(void)_goArticles {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_NOW_PLAYING" object:nil];
}

-(void)_goOptions {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_OPTIONS" object:nil];
}

@end
