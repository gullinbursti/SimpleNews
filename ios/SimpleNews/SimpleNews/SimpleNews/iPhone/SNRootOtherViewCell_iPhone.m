//
//  SNRootOtherViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNRootOtherViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNRootOtherViewCell_iPhone

@synthesize overlayView = _overlayView;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)initWithTitle:(NSString *)title {
	if ((self = [super init])) {
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 12.0, 256.0, 28.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.text = title;
		[self addSubview:_nameLabel];
		
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(186.0, 14.0, 24.0, 24.0)];
		chevronView.image = [UIImage imageNamed:@"chevron.png"];
		[self addSubview:chevronView];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 50.0, self.frame.size.width, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:2.0 topCapHeight:0.0];
		[self addSubview:lineImgView];
		
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 50.0)];
		[_overlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.125]];
		_overlayView.alpha = 0.0;
		[self addSubview:_overlayView];
	}
	
	return (self);
}

@end
