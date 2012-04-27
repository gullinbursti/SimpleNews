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
		
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 200.0, 24.0)];
		titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:18];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		titleLabel.text = _vo.list_name;
		[self addSubview:titleLabel];
		
		CGSize size = [@"created by " sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *createdLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 35.0, size.width, size.height)];
		createdLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		createdLabel.textColor = [UIColor colorWithWhite:0.824 alpha:1.0];
		createdLabel.backgroundColor = [UIColor clearColor];
		createdLabel.text = @"created by ";
		[self addSubview:createdLabel];
		
		UILabel *curatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + size.width, 35.0, 200.0, 20.0)];
		curatorLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14];
		curatorLabel.textColor = [SNAppDelegate snLinkColor];
		curatorLabel.backgroundColor = [UIColor clearColor];
		curatorLabel.text = _vo.curatorHandles;
		[self addSubview:curatorLabel];
	}
	
	return (self);
}


-(void)dealloc {
}

@end
