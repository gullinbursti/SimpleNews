//
//  SNPaginationView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNPaginationView.h"

#define LED_SIZE 14.0
#define MARGIN_SIZE 16.0
#define SPACING_SIZE 8.0

@implementation SNPaginationView

-(id)initWithTotal:(int)total coords:(CGPoint)pos {
	if ((self = [super initWithFrame:CGRectMake(pos.x - ((total * LED_SIZE) * 0.5), pos.y, total * LED_SIZE, LED_SIZE)])) {
		_totPages = total;
		_currPage = 0.0;
		
		_bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_bgButton.frame = CGRectMake(-MARGIN_SIZE, -17.0, 32.0 + (total * LED_SIZE), 34.0);
		[_bgButton setBackgroundImage:[[UIImage imageNamed:@"paginationBG.png"] stretchableImageWithLeftCapWidth:17.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[_bgButton setBackgroundImage:[[UIImage imageNamed:@"paginationBG.png"] stretchableImageWithLeftCapWidth:17.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[_bgButton addTarget:self action:@selector(_goDerp) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_bgButton];
		
		int xOffset = 0;
		
		for (int i=0; i<_totPages; i++) {
			UIImageView *ledImgView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, -(LED_SIZE * 0.5), LED_SIZE, LED_SIZE)];
			[ledImgView setImage:[UIImage imageNamed:@"pagination_nonActive.png"]];
			[self addSubview:ledImgView];
			xOffset += (4.0 + SPACING_SIZE);
		}
		
		_onImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -(LED_SIZE * 0.5), LED_SIZE, LED_SIZE)];
		[_onImgView setImage:[UIImage imageNamed:@"paginationActive.png"]];
		[self addSubview:_onImgView];
	}
	
	return (self);
}

-(void)updToPage:(int)page {
	_currPage = page;
	_onImgView.frame = CGRectMake(_currPage * (4.0 + SPACING_SIZE), -(LED_SIZE * 0.5), LED_SIZE, LED_SIZE);
}

-(void)_goDerp {
	
}

-(void)dealloc {
}

@end
