//
//  SNVideoItemViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoItemViewCell_iPhone.h"

@implementation SNVideoItemViewCell_iPhone

@synthesize vo = _vo;
@synthesize shouldDrawSeparator = _shouldDrawSeparator;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, -34.0, self.frame.size.width, 200.0)];
		_imgView.alpha = 0.85;
		[self addSubview:_imgView];
		
		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -34.0, self.frame.size.width, 200.0)];
		[_overlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		_overlayView.hidden = YES;
		[self addSubview:_overlayView];
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)setVo:(SNVideoItemVO *)vo {
	_vo = vo;
	
	_imgView.imageURL = [NSURL URLWithString:vo.thumb_url];
}

- (void)setShouldDrawSeparator:(BOOL)shouldDrawSeparator {
	_shouldDrawSeparator = shouldDrawSeparator;
	[[self viewWithTag:1] setHidden:shouldDrawSeparator];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	//[super setSelected:selected animated:animated];
	
	_overlayView.hidden = !selected;
}

@end
