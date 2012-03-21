//
//  SNLoaderView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNLoaderView_iPhone.h"

@interface SNLoaderView_iPhone()
-(void)_resetHighlight;
-(void)_showMe;
-(void)_hideMe;
@end

@implementation SNLoaderView_iPhone

@synthesize isLoading;

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.isLoading = NO;
		[self _hideMe];
		
		_bgView = [[UIView alloc] initWithFrame:self.frame];
		[_bgView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
		_bgView.alpha = 0.0;
		[self addSubview:_bgView];
		
		_stripsImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		_stripsImgView.image = [UIImage imageNamed:@"loaderBG.jpg"];
		[self addSubview:_stripsImgView];
		
		_highlightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-74.0, 12.0, 74.0, 9.0)];
		_highlightImgView.image = [UIImage imageNamed:@"loaderHighlight.png"];
		_highlightImgView.hidden = YES;
		[self addSubview:_highlightImgView];
	}
	
	return (self);
}

-(void)dealloc {
	[_bgView release];
	[_stripsImgView release];
	[_highlightImgView release];
	
	[super dealloc];
}


-(void)introMe {
	[self _showMe];
	self.isLoading = YES;
	
	_bgView.alpha = 0.0;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
		_bgView.alpha = 0.85;
		_stripsImgView.frame = CGRectMake(_stripsImgView.frame.origin.x, -self.frame.size.height + 20.0, _stripsImgView.frame.size.width, _stripsImgView.frame.size.height);
	
	} completion:^(BOOL finished) {
		_highlightImgView.frame = CGRectMake(-_highlightImgView.frame.size.width, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
		_highlightImgView.hidden = NO;
		[self _resetHighlight];
		
		_timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(_resetHighlight) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
		
	}];
}

-(void)outroMe {
	_highlightImgView.hidden = YES;
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
		_bgView.alpha = 0.0;
		_stripsImgView.frame = CGRectMake(_stripsImgView.frame.origin.x, -self.frame.size.height, _stripsImgView.frame.size.width, _stripsImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
		self.isLoading = NO;
	}];
	
	//[_timer invalidate];
	_timer = nil;
	[self performSelector:@selector(_hideMe) withObject:nil afterDelay:0.33];
}

-(void)_resetHighlight {
	_highlightImgView.frame = CGRectMake(-_highlightImgView.frame.size.width, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
	
	[UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
		_highlightImgView.frame = CGRectMake(self.frame.size.width, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
	} completion:nil];
}

-(void)_showMe {
	self.hidden = NO;
	_highlightImgView.hidden = NO;
}

-(void)_hideMe {
	self.hidden = YES;
	_highlightImgView.hidden = YES;
}

@end
