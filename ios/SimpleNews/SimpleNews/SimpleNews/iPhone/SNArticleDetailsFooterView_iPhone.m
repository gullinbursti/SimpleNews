//
//  SNArticleDetailsFooterView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.19.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleDetailsFooterView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNArticleDetailsFooterView_iPhone

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, 480.0 - 46.0, 320.0, 46.0)])) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.941 alpha:1.0]];
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[SNAppDelegate snLineColor]];
		[self addSubview:lineView];
		
		
		UIButton *likeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		likeButton.frame = CGRectMake(6.0, 6.0, 44.0, 34.0);
		[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:likeButton];
		
		UIButton *commentButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		commentButton.frame = CGRectMake(54.0, 6.0, 84.0, 34.0);
		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive.png"] forState:UIControlStateNormal];
		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active.png"] forState:UIControlStateHighlighted];
		commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:9.0];
		commentButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		commentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -10.0);
		[commentButton setTitle:@"Comments" forState:UIControlStateNormal];
		[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:commentButton];
		
		UIButton *shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		shareButton.frame = CGRectMake(265.0, 6.0, 49.0, 34.0);
		[shareButton setBackgroundImage:[UIImage imageNamed:@"moreOptionsButton_nonActive.png"] forState:UIControlStateNormal];
		[shareButton setBackgroundImage:[UIImage imageNamed:@"moreOptionsButton_Active.png"] forState:UIControlStateHighlighted];
		[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:shareButton];
	}
	
	return (self);
}

#pragma mark - Navigation
-(void)_goLike {
	
}

-(void)_goComment {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DETAILS_SHOW_COMMENTS" object:nil];
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DETAILS_SHOW_SHARE" object:nil];
}

@end
