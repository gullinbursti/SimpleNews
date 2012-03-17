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
		
		_gridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_gridButton.frame = CGRectMake(12.0, 2.0, 24.0, 24.0);
		[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridIcon_nonActive.png"] forState:UIControlStateNormal];
		[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridIcon_Active.png"] forState:UIControlStateHighlighted];		
		[_gridButton addTarget:self action:@selector(_goGrid) forControlEvents:UIControlEventTouchUpInside];		
		[self addSubview:_gridButton];
		
		UIButton *cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		cancelButton.frame = CGRectMake(230.0, 8.0, 82.0, 34.0);
		[cancelButton setBackgroundImage:[[UIImage imageNamed:@"fbNoThanksButton.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[[UIImage imageNamed:@"fbNoThanksButton.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		cancelButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14.0];
		cancelButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		cancelButton.titleLabel.shadowColor = [UIColor blackColor];
		cancelButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[cancelButton setTitle:@"No Thanks" forState:UIControlStateNormal];
		[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cancelButton];
		
		UIButton *connectButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		connectButton.frame = CGRectMake(38.0, 400.0, 244.0, 64.0);
		[connectButton setBackgroundImage:[[UIImage imageNamed:@"facebookButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[connectButton setBackgroundImage:[[UIImage imageNamed:@"facebookButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		connectButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14.0];
		connectButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		connectButton.titleLabel.shadowColor = [UIColor blackColor];
		connectButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[connectButton setTitle:@"Connect to Facebook" forState:UIControlStateNormal];
		[connectButton addTarget:self action:@selector(_goConnect) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:connectButton];
		
		_scaledImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width - (self.frame.size.width * kImageScale)) * 0.5), ((self.frame.size.height - (self.frame.size.height * kImageScale)) * 0.5), self.frame.size.width * kImageScale, self.frame.size.height * kImageScale)] autorelease];
		_scaledImgView.image = [UIImage imageWithCGImage:[[SNAppDelegate imageWithView:_holderView] CGImage] scale:1.0 orientation:UIImageOrientationUp];
		[self addSubview:_scaledImgView];
		
		_holderView.hidden = YES;
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];
}


#pragma mark - Navigation
-(void)_goGrid {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LEAVE_ARTICLES" object:nil];
}

-(void)_goCancel {
	
}

-(void)_goConnect {
	
}

@end
