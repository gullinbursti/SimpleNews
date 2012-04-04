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

@implementation SNListCardView_iPhone

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		_isExpanded = NO;
		
		_testImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, -6.0, self.frame.size.width, self.frame.size.height)] autorelease];
		_testImgView.image = [UIImage imageNamed:@"storyImageTest.jpg"];
		_testImgView.layer.cornerRadius = 8.0;
		_testImgView.clipsToBounds = YES;
		_testImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_testImgView.layer.borderWidth = 1.0;
		[self addSubview:_testImgView];
		
		
		CABasicAnimation *initAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		initAnimation.beginTime = CACurrentMediaTime();
		initAnimation.toValue = [NSNumber numberWithDouble:0.93];
		initAnimation.duration = 0.1;
		initAnimation.fillMode = kCAFillModeForwards;
		initAnimation.removedOnCompletion = NO;
		[_testImgView.layer addAnimation:initAnimation forKey:@"initAnimation"];
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(82.0, 410.0, 200.0, 20.0)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = _vo.list_name;
		[self addSubview:titleLabel];
		
		UILabel *curatorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(82.0, 430.0, 200.0, 20.0)] autorelease];
		curatorLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:14];
		curatorLabel.textColor = [UIColor colorWithWhite:0.325 alpha:1.0];
		curatorLabel.backgroundColor = [UIColor clearColor];
		
		if (_vo.totalSubscribers == 1)
			curatorLabel.text = [NSString stringWithFormat:@"By %@ • %@ subscriber", _vo.curator, _vo.subscribersFormatted];
		
		else
			curatorLabel.text = [NSString stringWithFormat:@"By %@ • %@ subscribers", _vo.curator, _vo.subscribersFormatted];
		
		[self addSubview:curatorLabel];
		
		_influencersView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 360.0, self.frame.size.width, 320.0)];
		[_influencersView setBackgroundColor:[UIColor whiteColor]];
		_influencersView.hidden = YES;
		[self addSubview:_influencersView];
		
		
		UIImageView *gripImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(128.0, 350.0, 64.0, 64.0)] autorelease];
		gripImgView.image = [UIImage imageNamed:@"grip.png"];
		[self addSubview:gripImgView];
		
		
		UIButton *articlesButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		articlesButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
		[articlesButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:articlesButton];
		
		UIButton *subscribeBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		subscribeBtn.frame = CGRectMake(214.0, 23, 83.0, 35.0);
		[subscribeBtn setBackgroundImage:[UIImage imageNamed:@"readMoreButton_nonActive.png"] forState:UIControlStateNormal];
		[subscribeBtn setBackgroundImage:[UIImage imageNamed:@"readMoreButton_Active.png"] forState:UIControlStateHighlighted];
		subscribeBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
		subscribeBtn.titleLabel.textAlignment = UITextAlignmentCenter;
		[subscribeBtn setTitleColor:[UIColor colorWithWhite:0.235 alpha:1.0] forState:UIControlStateNormal];
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
		_influencersView.hidden = NO;
		
		[UIView animateWithDuration:0.33 animations:^(void){
			_influencersView.frame = CGRectMake(_influencersView.frame.origin.x, 12.0, _influencersView.frame.size.width, _influencersView.frame.size.height);
		} completion:^(BOOL finished){
			
		}];
	
	} else {
		[UIView animateWithDuration:0.33 animations:^(void){
			_influencersView.frame = CGRectMake(_influencersView.frame.origin.x, 360.0, _influencersView.frame.size.width, _influencersView.frame.size.height);
			
		} completion:^(BOOL finished){
			_influencersView.hidden = YES;
		}];
	}
}


#pragma mark - Navigation
-(void)_goArticles {
	CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	zoomAnimation.beginTime = CACurrentMediaTime();
	zoomAnimation.toValue = [NSNumber numberWithDouble:1.0];
	zoomAnimation.duration = 0.15;
	zoomAnimation.fillMode = kCAFillModeForwards;
	zoomAnimation.removedOnCompletion = NO;
	[_testImgView.layer addAnimation:zoomAnimation forKey:@"zoomAnimation"];
	
	[UIView animateWithDuration:0.15 animations:^(void) {
		_testImgView.frame = CGRectMake(_testImgView.frame.origin.x, _testImgView.frame.origin.y + 6, _testImgView.frame.size.width, _testImgView.frame.size.height);
	
	} completion:^(BOOL finished){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_ARTICLES" object:_vo];
		_testImgView.frame = CGRectMake(_testImgView.frame.origin.x, _testImgView.frame.origin.y - 6, _testImgView.frame.size.width, _testImgView.frame.size.height);
		
		CABasicAnimation *initAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		initAnimation.beginTime = CACurrentMediaTime();
		initAnimation.toValue = [NSNumber numberWithDouble:0.93];
		initAnimation.duration = 0.1;
		initAnimation.fillMode = kCAFillModeForwards;
		initAnimation.removedOnCompletion = NO;
		[_testImgView.layer addAnimation:initAnimation forKey:@"initAnimation"];
	}];
	
//	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//	animationGroup.animations = [NSArray arrayWithObjects:zoomAnimation, scaleAnim, opacityAnim, nil];
//	animationGroup.duration = 0.5;
//	[_testImgView.layer addAnimation:animationGroup forKey:nil];
	
	
	//
}

-(void)_goSubscribe {
	
}

@end
