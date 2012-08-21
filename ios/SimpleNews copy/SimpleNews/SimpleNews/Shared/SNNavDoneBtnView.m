//
//  SNNavDoneBtnView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNNavDoneBtnView.h"
#import "SNAppDelegate.h"

@implementation SNNavDoneBtnView
@synthesize btn = _btn;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_btn = [UIButton buttonWithType:UIButtonTypeCustom];
		_btn.frame = CGRectMake(1.0, -1.0, frame.size.width, frame.size.height);
		[_btn setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive.png"] forState:UIControlStateNormal];
		[_btn setBackgroundImage:[UIImage imageNamed:@"doneButton_Active.png"] forState:UIControlStateHighlighted];		
		_btn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		//_btn.titleLabel.shadowColor = [UIColor blackColor];
		//_btn.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		//_btn.titleEdgeInsets = UIEdgeInsetsMake(1, 3, -1, -3);
		[_btn setTitle:@"Done" forState:UIControlStateNormal];
		[self addSubview:_btn];
	}
	
	return (self);
}

@end
