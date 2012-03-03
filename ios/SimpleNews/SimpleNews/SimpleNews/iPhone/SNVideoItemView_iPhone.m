//
//  SNVideoItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoItemView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNVideoItemView_iPhone

@synthesize vo = _vo;

-(id)initWithFrame:(CGRect)frame videoItemVO:(SNVideoItemVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		NSLog(@"IMAGE:[%@]", _vo.thumb_url);
		
		[self setBackgroundColor:[UIColor blackColor]];
		self.clipsToBounds = YES;
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 200.0)];
		_imageView.imageURL = [NSURL URLWithString:_vo.thumb_url];
		_imageView.alpha = 0.5;
		[self addSubview:_imageView];
		
		UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 43.0)] autorelease];
		[bgView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
		[self addSubview:bgView];
		
		_channelImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 33.0, 33.0)];
		_channelImageView.imageURL = [NSURL URLWithString:_vo.image_url];
		[self addSubview:_channelImageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0, 10.0, self.frame.size.width - 52.0, 22.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:16.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = _vo.video_title;
		[self addSubview:_titleLabel];
		
		UIImageView *hdImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(284.0, 169.0, 24.0, 24.0)] autorelease];
		hdImgView.image = [UIImage imageNamed:@"hd.png"];
		[self addSubview:hdImgView];
	}
	
	return (self);
}

-(void)dealloc {
	_imageView = nil;
	_titleLabel = nil;
	
	[super dealloc];
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == self) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:_vo];
		return;
	}		
}


-(void)fadeTo:(float)opac {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_imageView.alpha = opac;
	}];
}

@end
