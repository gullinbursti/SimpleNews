//
//  SNWeatherGadgetView_Airplay.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNWeatherGadgetView_Airplay.h"

#import "SNAppDelegate.h"

@implementation SNWeatherGadgetView_Airplay

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 64.0)];
		_imageView.image = [UIImage imageNamed:@"weatherWidgetSun.png"];
		[self addSubview:_imageView];

		
		_forecastLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 24.0, 200.0, 18.0)];
		_forecastLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14.0];
		_forecastLabel.backgroundColor = [UIColor clearColor];
		_forecastLabel.textColor = [UIColor whiteColor];
		_forecastLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_forecastLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_forecastLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_forecastLabel.text = @"Sunny in Menlo Park";
		[self addSubview:_forecastLabel];
	}
	
	return (self);
}


@end
