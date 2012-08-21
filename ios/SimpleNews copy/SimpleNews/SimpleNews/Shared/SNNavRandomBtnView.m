//
//  SNNavRandomBtnView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNNavRandomBtnView.h"

@implementation SNNavRandomBtnView

@synthesize btn = _btn;

- (id)initWithFrame:(CGRect)frame {
	
	if ((self = [super initWithFrame:frame])) {
		_btn = [UIButton buttonWithType:UIButtonTypeCustom];
		_btn.frame = CGRectMake(-1.0, -1.0, frame.size.width, frame.size.height);
		[_btn setBackgroundImage:[UIImage imageNamed:@"randomIcon_nonActive.png"] forState:UIControlStateNormal];
		[_btn setBackgroundImage:[UIImage imageNamed:@"randomIcon_Active.png"] forState:UIControlStateHighlighted];		
		[self addSubview:_btn];
	}
	
	return (self);
}

@end
