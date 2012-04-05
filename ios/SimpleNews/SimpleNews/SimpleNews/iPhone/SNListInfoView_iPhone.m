//
//  SNListInfoView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNListInfoView_iPhone.h"
#import "SNAppDelegate.h"
#import "EGOImageView.h"

@implementation SNListInfoView_iPhone

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		EGOImageView *thumbImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(10.0, 0.0, 50.0, 50.0)] autorelease];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.thumbURL];
		[self addSubview:thumbImgView];
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70.0, 10.0, 200.0, 20.0)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = _vo.list_name;
		[self addSubview:titleLabel];
		
		UILabel *curatorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70.0, 30.0, 200.0, 20.0)] autorelease];
		curatorLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14];
		curatorLabel.textColor = [UIColor colorWithWhite:0.325 alpha:1.0];
		curatorLabel.backgroundColor = [UIColor clearColor];
		
		if (_vo.totalSubscribers == 1)
			curatorLabel.text = [NSString stringWithFormat:@"By %@ • %@ subscriber", _vo.curator, _vo.subscribersFormatted];
		
		else
			curatorLabel.text = [NSString stringWithFormat:@"By %@ • %@ subscribers", _vo.curator, _vo.subscribersFormatted];
		
		[self addSubview:curatorLabel];
	}
	
	return (self);
}


-(void)dealloc {
	[super dealloc];
}

@end
