//
//  SNListInfoView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNListInfoView_iPhone.h"
#import "SNAppDelegate.h"
#import "SNCuratorVO.h"

@implementation SNListInfoView_iPhone

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.67]];
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 200.0, 24.0)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:18];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		titleLabel.text = _vo.list_name;
		[self addSubview:titleLabel];
		
		NSString *curators = @"by ";
		
		for (SNCuratorVO *vo in _vo.curators)
			curators = [curators stringByAppendingString:[NSString stringWithFormat:@"%@, ", vo.curator_name]];
		
		UILabel *curatorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15.0, 35.0, 200.0, 20.0)] autorelease];
		curatorLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14];
		curatorLabel.textColor = [UIColor colorWithWhite:0.824 alpha:1.0];
		curatorLabel.backgroundColor = [UIColor clearColor];
		curatorLabel.text = [curators substringToIndex:[curators length] - 2];
		
		[self addSubview:curatorLabel];
	}
	
	return (self);
}


-(void)dealloc {
	[super dealloc];
}

@end
