//
//  SNListCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNListCardView_iPhone.h"
#import "SNAppDelegate.h"
#import "SNListInfoView_iPhone.h"
#import "EGOImageView.h"

@implementation SNListCardView_iPhone

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		_isFlipped = NO;
		
		_holderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 12.0, 300.0, 450.0)];
		[_holderView setBackgroundColor:[UIColor whiteColor]];
		_holderView.layer.cornerRadius = 8.0;
		_holderView.clipsToBounds = YES;
		_holderView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_holderView.layer.borderWidth = 1.0;
		[self addSubview:_holderView];
		
		_testImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
		_testImgView.image = [UIImage imageNamed:@"storyImageTest.jpg"];
		//[self addSubview:_testImgView];
		
		EGOImageView *coverImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 280.0, 389.0)] autorelease];
		coverImgView.imageURL = [NSURL URLWithString:_vo.imageURL];
		[_holderView addSubview:coverImgView];
		
		CABasicAnimation *initAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		initAnimation.beginTime = CACurrentMediaTime();
		initAnimation.toValue = [NSNumber numberWithDouble:0.93];
		initAnimation.duration = 0.1;
		initAnimation.fillMode = kCAFillModeForwards;
		initAnimation.removedOnCompletion = NO;
		//[coverImgView.layer addAnimation:initAnimation forKey:@"initAnimation"];
		
		SNListInfoView_iPhone *listInfoView = [[SNListInfoView_iPhone alloc] initWithFrame:CGRectMake(10.0, 10.0, _holderView.frame.size.width - 20.0, 80.0) listVO:_vo];
		[_holderView addSubview:listInfoView];
		
		UIImageView *verifiedImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(12.0, 412.0, 24.0, 24.0)] autorelease];
		verifiedImgView.image = [UIImage imageNamed:@"verifiedIcon.png"];
		[_holderView addSubview:verifiedImgView];
		
		UILabel *verifiedLabel = [[[UILabel alloc] initWithFrame:CGRectMake(42.0, 414.0, 256.0, 20.0)] autorelease];
		verifiedLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		verifiedLabel.textColor = [UIColor blackColor];
		verifiedLabel.backgroundColor = [UIColor clearColor];
		verifiedLabel.text = @"Verified";
		[_holderView addSubview:verifiedLabel];
		
		_articlesButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_articlesButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[_articlesButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_articlesButton];
		
		_flipBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_flipBtn.frame = CGRectMake(245.0, 35.0, 49.0, 49.0);
		[_flipBtn setBackgroundImage:[UIImage imageNamed:@"flipListButton_nonActive.png"] forState:UIControlStateNormal];
		[_flipBtn setBackgroundImage:[UIImage imageNamed:@"flipListButton_Active.png"] forState:UIControlStateHighlighted];
		[_flipBtn addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_flipBtn];
		
		UIButton *subscribeBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		subscribeBtn.frame = CGRectMake(210.0, 410.0, 80.0, 25.0);
		[subscribeBtn setBackgroundColor:[UIColor blackColor]];
		subscribeBtn.layer.cornerRadius = 3.0;
		subscribeBtn.clipsToBounds = YES;
		subscribeBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11.0];
		subscribeBtn.titleLabel.textAlignment = UITextAlignmentCenter;
		[subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[subscribeBtn setTitle:@"Follow Topic" forState:UIControlStateNormal];
		[subscribeBtn addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		[_holderView addSubview:subscribeBtn];
		
		_doneButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_doneButton.frame = CGRectMake(246.0, 23.0, 50.0, 25.0);
		[_doneButton setBackgroundColor:[UIColor blackColor]];
		_doneButton.layer.cornerRadius = 3.0;
		_doneButton.clipsToBounds = YES;
		_doneButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11.0];
		_doneButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_doneButton setTitle:@"Done" forState:UIControlStateNormal];
		[_doneButton addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
		_doneButton.alpha = 0.0;
		[self addSubview:_doneButton];
		
		_influencersListView = [[SNInfluencersListView alloc] initWithFrame:CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height) listVO:_vo];
		[_influencersListView setBackgroundColor:[UIColor whiteColor]];
		
		
//		
//		UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_goFlip:)];
//		swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
//		[self addGestureRecognizer:swipeUpRecognizer];
//		[swipeUpRecognizer release];
//		
//		UISwipeGestureRecognizer *swipDnRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_goFlip:)];
//		swipDnRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
//		[self addGestureRecognizer:swipDnRecognizer];
//		[swipDnRecognizer release];
	}
	
	return (self);
}

#pragma mark - Interaction handlers
-(void)_goFlip {
	NSLog(@"LIST");
	
	_isFlipped = !_isFlipped;
	
	
	if (_isFlipped) {
		[_articlesButton removeTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		
		[UIView animateWithDuration:0.125 animations:^(void) {
			_flipBtn.alpha = 0.0;
			
		} completion:^(BOOL finished) {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_holderView cache:YES];
			[UIView commitAnimations];
			[_holderView addSubview:_influencersListView];
			
			[UIView animateWithDuration:0.125 delay:0.33 options:UIViewAnimationCurveLinear animations:^(void) {
				_doneButton.alpha = 1.0;
			} completion:nil];
		}];
		
	} else {
		[_articlesButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_holderView cache:YES];
		[UIView commitAnimations];
		[_influencersListView removeFromSuperview];
		
		[UIView animateWithDuration:0.125 animations:^(void) {
			_doneButton.alpha = 0.0;
		} completion:nil];
		
		[UIView animateWithDuration:0.125 delay:0.33 options:UIViewAnimationCurveLinear animations:^(void) {
			_flipBtn.alpha = 1.0;
		} completion:nil];
	}
}


#pragma mark - Navigation
-(void)_goArticles {
	CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	zoomAnimation.beginTime = CACurrentMediaTime();
	zoomAnimation.toValue = [NSNumber numberWithDouble:1.07];
	zoomAnimation.duration = 0.15;
	zoomAnimation.fillMode = kCAFillModeForwards;
	zoomAnimation.removedOnCompletion = NO;
	[_holderView.layer addAnimation:zoomAnimation forKey:@"zoomAnimation"];
	
	[self performSelector:@selector(_outroMe) withObject:nil afterDelay:0.2];
	
//	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//	animationGroup.animations = [NSArray arrayWithObjects:zoomAnimation, scaleAnim, opacityAnim, nil];
//	animationGroup.duration = 0.5;
//	[_testImgView.layer addAnimation:animationGroup forKey:nil];
	
	
	//
}

-(void)_goSubscribe {
	
}


-(void)_outroMe {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_ARTICLES" object:_vo];
	[self performSelector:@selector(_resetMe) withObject:nil afterDelay:0.33];
}

-(void)_resetMe {
	CABasicAnimation *resetAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	resetAnimation.beginTime = CACurrentMediaTime();
	resetAnimation.toValue = [NSNumber numberWithDouble:1.0];
	//resetAnimation.beginTime = CACurrentMediaTime() + 0.33;
	resetAnimation.duration = 0.1;
	resetAnimation.fillMode = kCAFillModeForwards;
	resetAnimation.removedOnCompletion = NO;
	[_holderView.layer addAnimation:resetAnimation forKey:@"resetAnimation"];
}

@end
