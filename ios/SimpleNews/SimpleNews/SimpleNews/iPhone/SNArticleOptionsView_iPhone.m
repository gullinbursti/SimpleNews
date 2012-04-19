//
//  SNArticleOptionsView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleOptionsView_iPhone.h"
#import "SNAppDelegate.h"

#define kFontKobsY 24.0
#define kKobInc 15.0

@implementation SNArticleOptionsView_iPhone

-(id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, -26.0, 320.0, 77.0)])) {
		_isRevealed = NO;
		_isDark = [SNAppDelegate isDarkStyleUI];
		_fontSize = [SNAppDelegate fontFactor];
		
		[self setBackgroundColor:[SNAppDelegate snHeaderColor]];
		
		UIButton *minusButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		minusButton.frame = CGRectMake(13.0, 20.0, 34.0, 34.0);
		[minusButton setBackgroundImage:[UIImage imageNamed:@"minus_nonActive.png"] forState:UIControlStateNormal];
		[minusButton setBackgroundImage:[UIImage imageNamed:@"minus_Active.png"] forState:UIControlStateHighlighted];
		[minusButton addTarget:self action:@selector(_goMinus) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:minusButton];
		
		UIButton *plusButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		plusButton.frame = CGRectMake(110.0, 20.0, 34.0, 34.0);
		[plusButton setBackgroundImage:[UIImage imageNamed:@"plus_nonActive.png"] forState:UIControlStateNormal];
		[plusButton setBackgroundImage:[UIImage imageNamed:@"plus_Active.png"] forState:UIControlStateHighlighted];
		[plusButton addTarget:self action:@selector(_goPlus) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:plusButton];
		
		UIImageView *sizeBGImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(47.0, 30.0, 64.0, 14.0)] autorelease];
		sizeBGImgView.image = [UIImage imageNamed:@"fontNotches.png"];
		[self addSubview:sizeBGImgView];
		
		_sizeIndicatorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(50.0 + (kKobInc * _fontSize), 30.0, 14.0, 14.0)];
		_sizeIndicatorImgView.image = [UIImage imageNamed:@"fontNotches_Selected.png"];
		[self addSubview:_sizeIndicatorImgView];
		
		UIButton *sunButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		sunButton.frame = CGRectMake(175.0, 25.0, 24.0, 24.0);
		[sunButton setBackgroundImage:[UIImage imageNamed:@"sunIcon_nonActive.png"] forState:UIControlStateNormal];
		[sunButton setBackgroundImage:[UIImage imageNamed:@"sunIcon_Active.png"] forState:UIControlStateHighlighted];
		[sunButton addTarget:self action:@selector(_goBright) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:sunButton];
		
		UIButton *moonButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		moonButton.frame = CGRectMake(285.0, 25.0, 24.0, 24.0);
		[moonButton setBackgroundImage:[UIImage imageNamed:@"moonIcon_nonActive.png"] forState:UIControlStateNormal];
		[moonButton setBackgroundImage:[UIImage imageNamed:@"moonIcon_Active.png"] forState:UIControlStateHighlighted];
		[moonButton addTarget:self action:@selector(_goDark) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:moonButton];
		
		UIImageView *brightnessBGImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(202.0, 20.0, 84.0, 34.0)] autorelease];
		brightnessBGImgView.image = [UIImage imageNamed:@"gripBackground.png"];
		[self addSubview:brightnessBGImgView];
		
		_brightnessButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		
		if (_isDark)
			_brightnessButton.frame = CGRectMake(250.0, 20.0, 34.0, 34.0);
		
		else
			_brightnessButton.frame = CGRectMake(204.0, 20.0, 34.0, 34.0);
		
		[_brightnessButton setBackgroundImage:[UIImage imageNamed:@"gripButton_nonActive.png"] forState:UIControlStateNormal];
		[_brightnessButton setBackgroundImage:[UIImage imageNamed:@"gripButton_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:_brightnessButton];
		
		UIView *centerLineView = [[[UIView alloc] initWithFrame:CGRectMake(160.0, 0.0, 1.0, 77.0)] autorelease];
		[centerLineView setBackgroundColor:[SNAppDelegate snLineColor]];
		[self addSubview:centerLineView];
		
		UIView *bottomLineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 77.0, 320.0, 1.0)] autorelease];
		[bottomLineView setBackgroundColor:[SNAppDelegate snLineColor]];
		[self addSubview:bottomLineView];
		
		
		UISwipeGestureRecognizer *swipeRtRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_swipeRt:)];
		swipeRtRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[self addGestureRecognizer:swipeRtRecognizer];
		[swipeRtRecognizer release];
		
		UISwipeGestureRecognizer *swipeLtRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_swipeLt:)];
		swipeLtRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		[self addGestureRecognizer:swipeLtRecognizer];
		[swipeLtRecognizer release];
	}
	
	return (self);
}


#pragma mark - Navigation
-(void)_goMinus {
	_fontSize = MIN(3, MAX(--_fontSize, 0));
	[SNAppDelegate writeFontFactor:_fontSize];
	_sizeIndicatorImgView.frame = CGRectMake(50.0 + (15.0 * _fontSize), _sizeIndicatorImgView.frame.origin.y, _sizeIndicatorImgView.frame.size.width, _sizeIndicatorImgView.frame.size.height);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_FONT_SIZE" object:[NSNumber numberWithInt:_fontSize]];
}

-(void)_goPlus {
	_fontSize = MIN(3, MAX(++_fontSize, 0));
	[SNAppDelegate writeFontFactor:_fontSize];
	_sizeIndicatorImgView.frame = CGRectMake(50.0 + (15.0 * _fontSize), _sizeIndicatorImgView.frame.origin.y, _sizeIndicatorImgView.frame.size.width, _sizeIndicatorImgView.frame.size.height);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_FONT_SIZE" object:[NSNumber numberWithInt:_fontSize]];
}

-(void)_goDark {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_brightnessButton.frame = CGRectMake(250.0, _brightnessButton.frame.origin.y, _brightnessButton.frame.size.width, _brightnessButton.frame.size.height);
	
	} completion:^(BOOL finished) {
		_isDark = YES;
		[SNAppDelegate writeDarkStyleUI:_isDark];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UI_THEMED_DARK" object:[NSNumber numberWithInt:_fontSize]];
	}];
}

-(void)_goBright {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_brightnessButton.frame = CGRectMake(204.0, _brightnessButton.frame.origin.y, _brightnessButton.frame.size.width, _brightnessButton.frame.size.height);
	
	} completion:^(BOOL finished) {
		_isDark = NO;
		[SNAppDelegate writeDarkStyleUI:_isDark];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UI_THEMED_LIGHT" object:[NSNumber numberWithInt:_fontSize]];
	}];
}

-(void)_swipeLt:(id)sender {
	[self _goBright];
}

-(void)_swipeRt:(id)sender {
	[self _goDark];
}


#pragma mark - Gesture Recongnizer Deleagtes
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	CGPoint touchPoint = [touch locationInView:self];
	
	if (CGRectContainsPoint(_brightnessButton.frame, touchPoint) && [touch.view isKindOfClass:[UIButton class]])
		return (YES);
	
	return (NO);
}

@end
