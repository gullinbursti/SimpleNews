//
//  SNListHeaderView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.18.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SNListHeaderView.h"

#import "SNAppDelegate.h"

@implementation SNListHeaderView

@synthesize btn = _btn;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 230.0, 45.0)];
		headerImgView.image = [UIImage imageNamed:@"leftMenuHeaderBG.png"];
		[self addSubview:headerImgView];
		
		UIView *profileHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 7.0, 34.0, 30.0)];
		profileHolderView.clipsToBounds = YES;
		profileHolderView.layer.cornerRadius = 4.0;
		[self addSubview:profileHolderView];
		
		EGOImageView *profileImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 35.0, 35.0)];
		[profileHolderView addSubview:profileImgView];
		CGSize size = [[NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(52.0, 14.0, size.width, size.height)];
		_label.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_label.textColor = [UIColor colorWithWhite:0.290 alpha:1.0];
		_label.backgroundColor = [UIColor clearColor];
		_label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_label.shadowOffset = CGSizeMake(1.0, 1.0);
		_label.text = [NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]];
		[self addSubview:_label];
		
		if ([SNAppDelegate twitterHandle].length == 0) {
			_label.text = @"";
			
		} else {
			profileImgView.imageURL = [NSURL URLWithString:[SNAppDelegate twitterAvatar]];
			
			_btn = [UIButton buttonWithType:UIButtonTypeCustom];
			_btn.frame = CGRectMake(7.0, 7.0, _label.frame.origin.x + size.width, 35.0);
			[self addSubview:_btn];
		}
	}
	
	return (self);
}



@end
