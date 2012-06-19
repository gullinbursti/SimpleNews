//
//  SNBaseRootViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.18.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNBaseRootViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNBaseRootViewCell_iPhone

@synthesize activeBGImgView = _activeBGImgView;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 227.0, 42.0)];
		bgImgView.image = [UIImage imageNamed:@"leftMenuRow.png"];
		[self addSubview:bgImgView];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 6.0, 256.0, 28.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:15];
		_nameLabel.textColor = [UIColor whiteColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
		
		_activeBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 227.0, 42.0)];
		_activeBGImgView.image = [UIImage imageNamed:@"leftMenuRowActive.png"];
		_activeBGImgView.alpha = 0.0;
		[self addSubview:_activeBGImgView];
	}
	
	return (self);
}


@end
