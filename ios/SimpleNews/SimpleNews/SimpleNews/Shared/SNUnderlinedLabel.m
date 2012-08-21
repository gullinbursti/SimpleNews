//
//  SNUnderlinedLabel.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.21.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNUnderlinedLabel.h"

@implementation SNUnderlinedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor(ctx, 0.0f / 255.0f, 0.0f / 255.0f, 0.0f / 255.0f, 1.0f);
	CGContextSetLineWidth(ctx, 1.0f);
	
	for (int i=1; i<=(int)(self.frame.size.height / self.font.leading); i++) {
		CGContextMoveToPoint(ctx, 0.0, (self.font.leading * i) - 2.0);
		CGContextAddLineToPoint(ctx, self.bounds.size.width, (self.font.leading * i) - 2.0);
	}
	
	CGContextStrokePath(ctx);
	
	[super drawRect:rect];  
}
@end
