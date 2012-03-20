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
@end

@implementation SNLoaderView_iPhone

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.hidden = YES;
		
		_bgView = [[UIView alloc] initWithFrame:self.frame];
		[_bgView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
		_bgView.alpha = 0.0;
		_bgView.hidden = YES;
		[self addSubview:_bgView];
		
		_stripsImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
		_stripsImgView.image = [UIImage imageNamed:@"loaderBG.jpg"];
		[self addSubview:_stripsImgView];
		
		_highlightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 12.0, 74.0, 9.0)];
		_highlightImgView.hidden = YES;
		_highlightImgView.image = [UIImage imageNamed:@"loaderHighlight.png"];
		[self addSubview:_highlightImgView];
		
		UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.frame] autorelease];
		overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
		[self addSubview:overlayImgView];
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
	self.hidden = NO;
	_bgView.alpha = 0.0;
	_bgView.hidden = NO;
	
	_highlightImgView.frame = CGRectMake(0.0, 12.0, 74.0, 9.0);
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
		_bgView.alpha = 0.85;
		_stripsImgView.frame = CGRectMake(_stripsImgView.frame.origin.x, -self.frame.size.height + 20.0, _stripsImgView.frame.size.width, _stripsImgView.frame.size.height);
	
	} completion:^(BOOL finished) {
		_highlightImgView.frame = CGRectMake(0.0, 12.0, 74.0, 9.0);
		_highlightImgView.hidden = NO;
		
		_timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(_resetHighlight) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
		
		[UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
			_highlightImgView.frame = CGRectMake(self.frame.size.width, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
		} completion:nil];
	}];
	
}

-(void)outroMe {
	_highlightImgView.hidden = YES;
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
		_bgView.alpha = 0.0;
		_stripsImgView.frame = CGRectMake(_stripsImgView.frame.origin.x, -self.frame.size.height, _stripsImgView.frame.size.width, _stripsImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_bgView.hidden = YES;
		self.hidden = YES;
	}];
		
	[_timer invalidate];
	_timer = nil;
}

-(void)_resetHighlight {
	_highlightImgView.frame = CGRectMake(0.0, 12.0, 74.0, 9.0);
	
	[UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
		_highlightImgView.frame = CGRectMake(self.frame.size.width, _highlightImgView.frame.origin.y, _highlightImgView.frame.size.width, _highlightImgView.frame.size.height);
	} completion:nil];
}

@end
