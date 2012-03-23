//
//  SNPaginationView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.19.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNPaginationView_iPhone.h"

@implementation SNPaginationView_iPhone

#define kOffset 14.0

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_currentPage = 0;
		
		float offset = 0.0;
		for (int i=0; i<3; i++) {
			UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(offset, 0.0, 9.0, 9.0)] autorelease];
			bgImgView.image = [UIImage imageNamed:@"pagination_off.png"];
			[self addSubview:bgImgView];
			
			offset += kOffset;
		}
		
		_onImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 9.0, 9.0)];
		_onImgView.image = [UIImage imageNamed:@"pagination_on.png"];
		[self addSubview:_onImgView];
	}
	
	return (self);
}

-(void)changePage:(int)page {
	_currentPage = page;
	_onImgView.frame = CGRectMake(_currentPage * kOffset, _onImgView.frame.origin.y, _onImgView.frame.size.width, _onImgView.frame.size.height);
}

-(void)dealloc {
	[_onImgView release];
	
	[super dealloc];	
}

@end
