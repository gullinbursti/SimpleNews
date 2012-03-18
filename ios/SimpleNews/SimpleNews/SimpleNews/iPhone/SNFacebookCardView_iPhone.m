//
//  SNFacebookCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFacebookCardView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNFacebookCardView_iPhone

#define kImageScale 0.9
#define kBaseHeaderHeight 90.0

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.frame] autorelease];
		bgImgView.image = [UIImage imageNamed:@"facebookAd.png"];
		[_holderView addSubview:bgImgView];
		
		_noThanksButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_noThanksButton.frame = CGRectMake(230.0, 8.0, 82.0, 34.0);
		[_noThanksButton setBackgroundImage:[[UIImage imageNamed:@"fbNoThanksButton.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_noThanksButton setBackgroundImage:[[UIImage imageNamed:@"fbNoThanksButton.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		_noThanksButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14.0];
		_noThanksButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_noThanksButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_noThanksButton.titleLabel.shadowColor = [UIColor blackColor];
		_noThanksButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[_noThanksButton setTitle:@"No Thanks" forState:UIControlStateNormal];
		[_noThanksButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_noThanksButton];
		
		_connectButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_connectButton.frame = CGRectMake(38.0, 400.0, 244.0, 64.0);
		[_connectButton setBackgroundImage:[[UIImage imageNamed:@"facebookButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_connectButton setBackgroundImage:[[UIImage imageNamed:@"facebookButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		_connectButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14.0];
		_connectButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_connectButton.titleLabel.shadowColor = [UIColor blackColor];
		_connectButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[_connectButton setTitle:@"Connect to Facebook" forState:UIControlStateNormal];
		[_connectButton addTarget:self action:@selector(_goConnect) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_connectButton];
		
		_scaledImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width - (self.frame.size.width * kImageScale)) * 0.5), ((self.frame.size.height - (self.frame.size.height * kImageScale)) * 0.5), self.frame.size.width * kImageScale, self.frame.size.height * kImageScale)] autorelease];
		_scaledImgView.image = [UIImage imageWithCGImage:[[SNAppDelegate imageWithView:self] CGImage] scale:1.0 orientation:UIImageOrientationUp];
		[self addSubview:_scaledImgView];
		
		_holderView.hidden = YES;
		_scaledImgView.hidden = YES;
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];
}

#pragma mark - Navigation
-(void)_goCancel {
	
}

-(void)_goConnect {
	
}

@end
