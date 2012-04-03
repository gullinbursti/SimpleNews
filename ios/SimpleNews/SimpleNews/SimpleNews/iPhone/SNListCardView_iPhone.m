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
		
		UIImageView *testImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, -6.0, self.frame.size.width, self.frame.size.height)] autorelease];
		testImgView.image = [UIImage imageNamed:@"storyImageTest.jpg"];
		testImgView.layer.cornerRadius = 8.0;
		testImgView.clipsToBounds = YES;
		testImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		testImgView.layer.borderWidth = 1.0;
		[self addSubview:testImgView];
		
		
		CABasicAnimation *initAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		initAnimation.beginTime = CACurrentMediaTime();
		initAnimation.toValue = [NSNumber numberWithDouble:0.93];
		initAnimation.duration = 0.1;
		initAnimation.fillMode = kCAFillModeForwards;
		initAnimation.removedOnCompletion = NO;
		[testImgView.layer addAnimation:initAnimation forKey:@"initAnimation"];
		
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
	}
	
	return (self);
}


#pragma mark - Navigation
-(void)_goArticles {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LIST_ARTICLES" object:_vo];
}

-(void)_goSubscribe {
	
}

@end
