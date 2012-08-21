//
//  SNComposeTypeView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNComposeTypeView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNComposeTypeView_iPhone

#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		_stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_stickerButton addTarget:self action:@selector(_goSticker) forControlEvents:UIControlEventTouchUpInside];
		_stickerButton.frame = CGRectMake(30.0, 250.0, 100.0, 48.0);
		[_stickerButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_stickerButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_stickerButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_stickerButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_stickerButton setTitle:@"Sticker" forState:UIControlStateNormal];
		[self addSubview:_stickerButton];
		
		_quoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_quoteButton addTarget:self action:@selector(_goQuote) forControlEvents:UIControlEventTouchUpInside];
		_quoteButton.frame = CGRectMake(190.0, 250.0, 100.0, 48.0);
		[_quoteButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateNormal];
		[_quoteButton setBackgroundImage:[[UIImage imageNamed:@"sendButton_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:12.0] forState:UIControlStateHighlighted];		
		[_quoteButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_quoteButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		[_quoteButton setTitle:@"Quote" forState:UIControlStateNormal];
		[self addSubview:_quoteButton];
	}
	
	return (self);
}

#pragma mark - Navigation
- (void)_goSticker {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_TYPE_STICKER" object:nil];
}

-(void)_goQuote {	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_TYPE_QUOTE" object:nil];
}


@end
