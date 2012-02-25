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
		
		[self setBackgroundColor:[UIColor blackColor]];
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 150.0)];
		_imageView.imageURL = [NSURL URLWithString:_vo.image_url];
		_imageView.alpha = 0.33;
		_imageView.clipsToBounds = YES;
		[self addSubview:_imageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 100, self.frame.size.width - 35, 22)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = _vo.video_title;
		[self addSubview:_titleLabel];
		
		_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 122, self.frame.size.width - 35, 16)];
		_infoLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
		_infoLabel.backgroundColor = [UIColor clearColor];
		_infoLabel.textColor = [UIColor whiteColor];
		_infoLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_infoLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_infoLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_infoLabel.text = _vo.video_info;
		[self addSubview:_infoLabel];
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 149.0, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor whiteColor]];
		//[self addSubview:lineView];
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
		NSLog(@"ENDED");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:_vo];
		return;
	}		
}

@end
