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
		_isExpanded = NO;
		
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
		
		_influencersListView = [[SNInfluencersListView alloc] initWithFrame:CGRectMake(12.0, 360.0, 297.0, 450.0) listVO:_vo];
		[_influencersListView setBackgroundColor:[UIColor whiteColor]];
		_influencersListView.hidden = YES;
		[self addSubview:_influencersListView];
		
		UIButton *articlesButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		articlesButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[articlesButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:articlesButton];
		
		UIButton *subscribeBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		subscribeBtn.frame = CGRectMake(214.0, 23, 84.0, 44.0);
		[subscribeBtn setBackgroundImage:[UIImage imageNamed:@"subscribeButton_nonActive.png"] forState:UIControlStateNormal];
		[subscribeBtn setBackgroundImage:[UIImage imageNamed:@"subscribeButton_Active.png"] forState:UIControlStateHighlighted];
		subscribeBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
		subscribeBtn.titleLabel.textAlignment = UITextAlignmentCenter;
		[subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[subscribeBtn setTitle:@"Subscribe" forState:UIControlStateNormal];
		[subscribeBtn addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:subscribeBtn];
		
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
	
	_isExpanded = !_isExpanded;
	
	
	if (_isExpanded) {
		_influencersListView.hidden = NO;
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_influencersListView.frame = CGRectMake(_influencersListView.frame.origin.x, 12.0, _influencersListView.frame.size.width, _influencersListView.frame.size.height);
		} completion:^(BOOL finished) {
			
		}];
	
	} else {
		[UIView animateWithDuration:0.33 animations:^(void) {
			_influencersListView.frame = CGRectMake(_influencersListView.frame.origin.x, 360.0, _influencersListView.frame.size.width, _influencersListView.frame.size.height);
			
		} completion:^(BOOL finished) {
			_influencersListView.hidden = YES;
		}];
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
