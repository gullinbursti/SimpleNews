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
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 33.0, 33.0)];
		[_imageView setBackgroundColor:[UIColor blackColor]];
		[self addSubview:_imageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 7.0, self.frame.size.width - 48.0, 18.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = @"";
		[self addSubview:_titleLabel];
	}
	
	return (self);
}


-(void)setVo:(SNVideoItemVO *)vo {
	_vo = vo;
	_titleLabel.text = _vo.video_title;
	_imageView.imageURL = [NSURL URLWithString:_vo.channelImg_url];
}

@end
