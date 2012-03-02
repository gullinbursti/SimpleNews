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
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 100.0, 320.0, 240.0)];
		_imageView.clipsToBounds = YES;
		_imageView.imageURL = [NSURL URLWithString:_vo.image_url];
		[_imageView setBackgroundColor:[UIColor greenColor]];
		//_imageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
		[self addSubview:_imageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 400, self.frame.size.width - 35, 22)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = UITextAlignmentCenter;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = _vo.video_title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

-(void)_goPlay {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:_vo];
}

@end
