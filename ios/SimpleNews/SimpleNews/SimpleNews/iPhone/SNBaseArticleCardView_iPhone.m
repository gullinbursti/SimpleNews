//
//  SNBaseArticleCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNBaseArticleCardView_iPhone.h"

@implementation SNBaseArticleCardView_iPhone

@synthesize holderView = _holderView;
@synthesize scaledImgView = _scaledImgView;

#define kImageScale 0.9
#define kBaseHeaderHeight 90.0

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_holderView];
	}
	
	return (self);
}

-(void)dealloc {
	[_holderView release];
	[_scaledImgView release];
	
	[super dealloc];
}

@end
