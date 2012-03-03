//
//  SNPlayingVideoItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNPlayingVideoItemView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNPlayingVideoItemView_iPhone

-(id)initWithFrame:(CGRect)frame withVO:(SNVideoItemVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
		_imageView.alpha = 0.15;
		_imageView.imageURL = [NSURL URLWithString:_vo.image_url];
		[self addSubview:_imageView];
		
		_textSize = [_vo.video_title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18] constrainedToSize:CGSizeMake(self.frame.size.width - 35.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_channelImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(27.0, 200.0, 44.0, 44.0)];
		_channelImageView.alpha = 0.0;
		_channelImageView.imageURL = [NSURL URLWithString:_vo.image_url];
		[self addSubview:_channelImageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0, (self.frame.size.height * 0.5) - (_textSize.height * 0.5), _textSize.width, _textSize.height)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.numberOfLines = 0;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = _vo.video_title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}


-(void)introMe {
	[UIView animateWithDuration:0.5 animations:^(void) {
		//float center = ((self.frame.size.height * 0.5) - ((64.0 + _textSize.height) * 0.5));
		
		_channelImageView.alpha = 1.0;
		_channelImageView.frame = CGRectMake(_channelImageView.frame.origin.x, _titleLabel.frame.origin.y - 32.0, _channelImageView.frame.size.width, _channelImageView.frame.size.height);
		_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, ((self.frame.size.height * 0.5) - (_textSize.height * 0.5)) + 32.0, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
	}];
}

-(void)outroMe {
	[UIView animateWithDuration:0.0 delay:0.33 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		_channelImageView.alpha = 0.0;
		_channelImageView.frame = CGRectMake(_channelImageView.frame.origin.x, 200.0, _channelImageView.frame.size.width, _channelImageView.frame.size.height);
		_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, (self.frame.size.height * 0.5) - (_textSize.height * 0.5), _titleLabel.frame.size.width, _titleLabel.frame.size.height);
	} completion:nil];	
}


@end
