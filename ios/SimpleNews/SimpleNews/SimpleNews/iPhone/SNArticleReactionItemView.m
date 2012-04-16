//
//  SNArticleReactionItemView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleReactionItemView.h"

#import "EGOImageView.h"
#import "SNAppDelegate.h"

#import "SNOptionsPageViewController.h"

@implementation SNArticleReactionItemView

-(id)initWithFrame:(CGRect)frame reactionVO:(SNReactionVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		EGOImageView *thumbImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 0.0, 25.0, 25.0)] autorelease];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.thumb_url];
		[self addSubview:thumbImgView];
		
		UIButton *thumbButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		thumbButton.frame = thumbImgView.frame;
		[thumbButton addTarget:self action:@selector(_goReactionProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:thumbButton];
		
		CGSize txtSize = [_vo.content sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		UIButton *contentButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		contentButton.frame = CGRectMake(45.0, 0.0, 255.0, 20.0 + txtSize.height);
		[contentButton setBackgroundImage:[[UIImage imageNamed:@"commentsBG.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:5.0] forState:UIControlStateNormal];
		[contentButton setBackgroundImage:[[UIImage imageNamed:@"commentsBG.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:5.0] forState:UIControlStateHighlighted];
		[contentButton addTarget:self action:@selector(_goReactionPage) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:contentButton];
		
		UILabel *contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60.0, 8.0, 230.0, txtSize.height)] autorelease];
		contentLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		contentLabel.textColor = [UIColor colorWithWhite:0.376 alpha:1.0];
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.text = _vo.content;
		contentLabel.numberOfLines = 0;
		[self addSubview:contentLabel];
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];	
}


#pragma mark - Navigation
-(void)_goReactionPage {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_REACTION_PAGE" object:[NSString stringWithFormat:@"https://twitter.com/#!/%@", _vo.twitterHandle]];
}

-(void)_goReactionProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_REACTION_PROFILE" object:_vo.reaction_url];
}


@end
