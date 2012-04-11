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
		
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.67]];
		
		//EGOImageView *thumbImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(10.0, 0.0, 50.0, 50.0)] autorelease];
		//thumbImgView.imageURL = [NSURL URLWithString:_vo.thumbURL];
		//[self addSubview:thumbImgView];
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15.0, 15.0, 200.0, 24.0)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:18];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = _vo.list_name;
		[self addSubview:titleLabel];
		
		UILabel *curatorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15.0, 40.0, 200.0, 20.0)] autorelease];
		curatorLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14];
		curatorLabel.textColor = [UIColor whiteColor];
		curatorLabel.backgroundColor = [UIColor clearColor];
		curatorLabel.text = [NSString stringWithFormat:@"By %@", _vo.curator];
		
		[self addSubview:curatorLabel];
	}
	
	return (self);
}


-(void)dealloc {
	[super dealloc];
}

@end
