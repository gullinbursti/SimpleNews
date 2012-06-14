//
//  SNPaginationView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNPaginationView.h"

#define kLEDSize 8.0
#define kSpacingSize 1.0

@implementation SNPaginationView

-(id)initWithTotal:(int)total coords:(CGPoint)pos {
	if ((self = [super initWithFrame:CGRectMake(pos.x - ((total * (kLEDSize + kSpacingSize)) * 0.5), pos.y, total * kLEDSize, kLEDSize)])) {
		_totPages = total;
		_currPage = 0;
		
		int xOffset = 0;
		for (int i=0; i<_totPages; i++) {
			UIImageView *ledImgView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, -(kLEDSize * 0.5), kLEDSize, kLEDSize)];
			[ledImgView setImage:[UIImage imageNamed:@"pagination_off.png"]];
			[self addSubview:ledImgView];
			xOffset += (kLEDSize + kSpacingSize);
		}
		
		_onImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -(kLEDSize * 0.5), kLEDSize, kLEDSize)];
		[_onImgView setImage:[UIImage imageNamed:@"pagination_on.png"]];
		[self addSubview:_onImgView];
	}
	
	return (self);
}

-(void)changeToPage:(int)page {
	_currPage = page;
	_onImgView.frame = CGRectMake(_currPage * (kLEDSize + kSpacingSize), -(kLEDSize * 0.5), kLEDSize, kLEDSize);
}

@end
