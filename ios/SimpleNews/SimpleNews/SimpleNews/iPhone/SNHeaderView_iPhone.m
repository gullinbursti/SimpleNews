//
//  SNHeaderView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNHeaderView_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNHeaderView_iPhone

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 53.0)])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 49.0)];
		bgImgView.image = [UIImage imageNamed:@"header.png"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

-(id)initWithTitle:(NSString *)title {
	if ((self = [self init])) {
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0, 12.0, 192.0, 20)];
		titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.text = title;
		[self addSubview:titleLabel];
	}
	
	return (self);
}

@end
