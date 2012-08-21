//
//  SNProfileViewCell.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNProfileViewCell.h"
#import "SNAppDelegate.h"

@implementation SNProfileViewCell

@synthesize profileVO = _profileVO;
@synthesize overlayView = _overlayView;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		[self setBackgroundColor:[UIColor clearColor]];
		 
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, 23.0, 256.0, 18.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_titleLabel];
		
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 64.0)];
		[_overlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.33]];
		_overlayView.alpha = 0.0;
		[self addSubview:_overlayView];
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)setProfileVO:(SNProfileVO *)profileVO {
	_profileVO = profileVO;
	_titleLabel.text = _profileVO.title;
}


//-(void)drawRect:(CGRect)rect {
//	CGContextRef ctx = UIGraphicsGetCurrentContext();
//	CGContextSetRGBStrokeColor(ctx, 0.545, 0.545, 0.545, 1.0);
//	CGContextMoveToPoint(ctx, 0.0, 73.0);
//	CGContextAddLineToPoint(ctx, 73.0, self.frame.size.width);
//	CGContextStrokePath(ctx);
//}

@end
