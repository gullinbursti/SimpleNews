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

@implementation SNListCardView_iPhone

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		_isFlipped = NO;
		
		_testImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
		_testImgView.image = [UIImage imageNamed:@"storyImageTest.jpg"];
		_testImgView.layer.cornerRadius = 8.0;
		_testImgView.clipsToBounds = YES;
		_testImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_testImgView.layer.borderWidth = 1.0;
		//[self addSubview:_testImgView];
		
		_coverImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
		_coverImgView.imageURL = [NSURL URLWithString:_vo.imageURL];
		[self addSubview:_coverImgView];
		
		CABasicAnimation *initAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		initAnimation.beginTime = CACurrentMediaTime();
		initAnimation.toValue = [NSNumber numberWithDouble:0.93];
		initAnimation.duration = 0.1;
		initAnimation.fillMode = kCAFillModeForwards;
		initAnimation.removedOnCompletion = NO;
		//[_coverImgView.layer addAnimation:initAnimation forKey:@"initAnimation"];
		
		_listInfoView = [[SNListInfoView_iPhone alloc] initWithFrame:CGRectMake(10.0, 400.0, self.frame.size.width - 30.0, 80.0) listVO:_vo];
		[self addSubview:_listInfoView];
		
		_influencersListView = [[SNInfluencersListView alloc] initWithFrame:CGRectMake(12.0, 12.0, 297.0, 450.0) listVO:_vo];
		[_influencersListView setBackgroundColor:[UIColor whiteColor]];
		
		_articlesButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_articlesButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[_articlesButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_articlesButton];
		
		_subscribeBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_subscribeBtn.frame = CGRectMake(214.0, 23, 84.0, 44.0);
		[_subscribeBtn setBackgroundImage:[UIImage imageNamed:@"subscribeButton_nonActive.png"] forState:UIControlStateNormal];
		[_subscribeBtn setBackgroundImage:[UIImage imageNamed:@"subscribeButton_Active.png"] forState:UIControlStateHighlighted];
		_subscribeBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
		_subscribeBtn.titleLabel.textAlignment = UITextAlignmentCenter;
		[_subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_subscribeBtn setTitle:@"Subscribe" forState:UIControlStateNormal];
		[_subscribeBtn addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_subscribeBtn];
		
		UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_goExpandCollapse:)];
		swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
		[self addGestureRecognizer:swipeUpRecognizer];
		[swipeUpRecognizer release];
		
		UISwipeGestureRecognizer *swipDnRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_goExpandCollapse:)];
		swipDnRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
		[self addGestureRecognizer:swipDnRecognizer];
		[swipDnRecognizer release];
	}
	
	return (self);
}

#pragma mark - Interaction handlers
-(void)_goExpandCollapse:(id)sender {
	NSLog(@"LIST");
	
	_isFlipped = !_isFlipped;
	
	
	if (_isFlipped) {
		[_articlesButton removeTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		
		[UIView animateWithDuration:0.125 animations:^(void) {
			_listInfoView.alpha = 0.0;
			_subscribeBtn.alpha = 0.0;
		
		} completion:^(BOOL finished) {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.33];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_coverImgView cache:YES];
			[UIView commitAnimations];
			[_coverImgView addSubview:_influencersListView];
		}];
		
	} else {
		[_articlesButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.33];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_coverImgView cache:YES];
		[UIView commitAnimations];
		[_influencersListView removeFromSuperview];
		
		[UIView animateWithDuration:0.25 delay:0.33 options:UIViewAnimationCurveLinear animations:^(void) {
			_listInfoView.alpha = 1.0;
			_subscribeBtn.alpha = 1.0;			
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
	[_coverImgView.layer addAnimation:zoomAnimation forKey:@"zoomAnimation"];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_listInfoView.alpha = 0.0;
	}];
	
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
	[_coverImgView.layer addAnimation:resetAnimation forKey:@"resetAnimation"];

	_listInfoView.alpha = 1.0;
}

@end
