//
//  SNVideoListHeaderView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.29.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoListHeaderView.h"

#import "SNAppDelegate.h"

@implementation SNVideoListHeaderView

@synthesize vo = _vo;

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 4.0, 300.0, 18.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = @"DERP";
		[self addSubview:_titleLabel];
	}
	
	return (self);
}


-(void)setVo:(SNVideoItemVO *)vo {
	_vo = vo;
	_titleLabel.text = _vo.video_title;
}

@end
