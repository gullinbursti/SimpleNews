//
//  SNOptionViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNOptionViewCell_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNOptionViewCell_iPhone

@synthesize optionVO = _optionVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 28.0, 256.0, 20.0)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_titleLabel];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 74.0, self.frame.size.width - 30.0, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:1.0 topCapHeight:2.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}


#pragma mark - Accessors
- (void)setOptionVO:(SNOptionVO *)optionVO {
	_optionVO = optionVO;
	
	_titleLabel.text = _optionVO.option_title;
}


//-(void)drawRect:(CGRect)rect {
//	CGContextRef ctx = UIGraphicsGetCurrentContext();
//	CGContextSetRGBStrokeColor(ctx, 0.545, 0.545, 0.545, 1.0);
//	CGContextMoveToPoint(ctx, 0.0, 73.0);
//	CGContextAddLineToPoint(ctx, 73.0, self.frame.size.width);
//	CGContextStrokePath(ctx);
//}

@end
