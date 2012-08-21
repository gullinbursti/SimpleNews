//
//  SNSplashHighlightView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.10.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNSplashHighlightView.h"

@implementation SNSplashHighlightView

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)])) {
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(4.0, 4.0, 72.0, 72.0)];
		[_overlayView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
		[self addSubview:_overlayView];
	}
	
	return (self);
}

-(void)dealloc {
}

@end
