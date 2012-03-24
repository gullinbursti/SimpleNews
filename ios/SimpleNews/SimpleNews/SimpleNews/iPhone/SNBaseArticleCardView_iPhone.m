//
//  SNBaseArticleCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNBaseArticleCardView_iPhone.h"
#import <QuartzCore/QuartzCore.h>

@implementation SNBaseArticleCardView_iPhone

@synthesize holderView = _holderView;
@synthesize scaledImgView = _scaledImgView;
@synthesize bgView = _bgView;

#define kImageScale 0.9
#define kBaseHeaderHeight 90.0

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_bgView];
		
		CABasicAnimation *initAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		initAnimation.beginTime = CACurrentMediaTime();
		initAnimation.toValue = [NSNumber numberWithDouble:0.9];
		initAnimation.duration = 0.1;
		initAnimation.fillMode = kCAFillModeForwards;
		initAnimation.removedOnCompletion = NO;
		[_bgView.layer addAnimation:initAnimation forKey:@"initAnimation"];
		
		_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_holderView];
	}
	
	return (self);
}

-(void)dealloc {
	[_bgView release];
	[_holderView release];
	[_scaledImgView release];
	
	[super dealloc];
}


#pragma mark - Interaction handlers
-(void)resetContent {
	
}

-(void)introContent {
	
}

@end
