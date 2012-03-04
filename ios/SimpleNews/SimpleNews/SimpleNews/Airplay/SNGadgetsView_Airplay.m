//
//  SNGadgetsView_Airplay.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNGadgetsView_Airplay.h"

@implementation SNGadgetsView_Airplay

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		//_bgView = [[UIView alloc] initWithFrame:CGRectMake(-64.0, -64.0, frame.size.width + 64.0, frame.size.height + 128.0)];
		_bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		[_bgView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		[self addSubview:_bgView];
		
		_weatherGadgetView = [[SNWeatherGadgetView_Airplay alloc] initWithFrame:CGRectMake(10.0, 10.0, 200.0, 150.0)];
		[self addSubview:_weatherGadgetView];
		
		_clockView = [[SNClockView alloc] initAtPosition:CGPointMake(10.0, 700.0)];
		[self addSubview:_clockView];
	}
	
	return (self);
}


@end
