//
//  SNClockView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNClockView.h"
#import "SNAppDelegate.h"

@implementation SNClockView

-(id)initAtPosition:(CGPoint)pos {
	if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, 200.0, 40.0)])) {
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
		_label.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:32.0];
		_label.backgroundColor = [UIColor clearColor];
		_label.textColor = [UIColor whiteColor];
		_label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_label.shadowOffset = CGSizeMake(1.0, 1.0);
		_label.text = @"";
		[self addSubview:_label];
		
		_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_onTick) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
	}
	
	return (self);
}


-(void)_onTick {
	NSDate *date = [NSDate date];
	
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	
	_label.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
}

@end
