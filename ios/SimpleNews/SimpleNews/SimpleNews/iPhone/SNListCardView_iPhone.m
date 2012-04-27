//
//  SNListCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GANTracker.h"
#import "SNListCardView_iPhone.h"
#import "SNAppDelegate.h"
#import "SNListInfoView_iPhone.h"
#import "EGOImageView.h"
#import "ASIFormDataRequest.h"

@implementation SNListCardView_iPhone

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		_isFlipped = NO;
		
		EGOImageView *coverImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height)];
		//coverImgView.imageURL = [NSURL URLWithString:_vo.imageURL];
		coverImgView.userInteractionEnabled = YES;
		[_holderView addSubview:coverImgView];
		
		coverImgView.image = [[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:_vo.imageURL] shouldLoadWithObserver:nil];
		
		SNListInfoView_iPhone *listInfoView = [[SNListInfoView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, _holderView.frame.size.width, 65.0) listVO:_vo];
		[_holderView addSubview:listInfoView];
		
		_articlesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_articlesButton.frame = CGRectMake(0.0, 0.0, coverImgView.frame.size.width, coverImgView.frame.size.height);
		[_articlesButton addTarget:self action:@selector(_goArticles) forControlEvents:UIControlEventTouchUpInside];
		[coverImgView addSubview:_articlesButton];
		
		_flipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipBtn.frame = CGRectMake(232.0, 22.0, 64.0, 44.0);
		[_flipBtn setBackgroundImage:[UIImage imageNamed:@"listInfluencersButton_nonActive.png"] forState:UIControlStateNormal];
		[_flipBtn setBackgroundImage:[UIImage imageNamed:@"listInfluencersButton_Active.png"] forState:UIControlStateHighlighted];
		[_flipBtn addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_flipBtn];
		
		UIView *btnBGView = [[UIView alloc] initWithFrame:CGRectMake(50.0, 365.0, 184.0, 35.0)];
		[btnBGView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
		btnBGView.layer.cornerRadius = 17.0;
		[_holderView addSubview:btnBGView];
		
		_subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_subscribeBtn.frame = CGRectMake(0.0, 0.0, 105.0, 44.0);
		[_subscribeBtn setBackgroundImage:[UIImage imageNamed:@"followTopicButton_nonActive.png"] forState:UIControlStateNormal];
		[_subscribeBtn setBackgroundImage:[UIImage imageNamed:@"followTopicButton_Active.png"] forState:UIControlStateHighlighted];
		[_subscribeBtn setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_subscribeBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11.0];
		_subscribeBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -10.0);
		
		if (_vo.isSubscribed) {
			[_subscribeBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
			[_subscribeBtn addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
		
		} else {
			[_subscribeBtn setTitle:@"Follow Topic" forState:UIControlStateNormal];
			[_subscribeBtn addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
		
		[btnBGView addSubview:_subscribeBtn];
		
		UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likesButton.frame = CGRectMake(125.0, 0.0, 65.0, 44.0);
		[likesButton setBackgroundImage:[UIImage imageNamed:@"likeButton_selected.png"] forState:UIControlStateNormal];
		[likesButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		likesButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11.0];
		likesButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
		[likesButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
		[btnBGView addSubview:likesButton];
				
		_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_doneButton.frame = CGRectMake(241.0, 18.0, 64.0, 44.0);
		[_doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive.png"] forState:UIControlStateNormal];
		[_doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonActive.png"] forState:UIControlStateHighlighted];
		[_doneButton addTarget:self action:@selector(_goFlip) forControlEvents:UIControlEventTouchUpInside];
		_doneButton.alpha = 0.0;
		[self addSubview:_doneButton];
		
		_influencersListView = [[SNInfluencersListView alloc] initWithFrame:CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height) listVO:_vo];
		[_influencersListView setBackgroundColor:[UIColor whiteColor]];
	}
	
	return (self);
}

#pragma mark - Interaction handlers
-(void)_goFlip {
	_isFlipped = !_isFlipped;	
	
	if (_isFlipped) {
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
	
	NSError *error;
	if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/lists/%@", _vo.list_name] withError:&error])
		NSLog(@"error in trackPageview");
	
	[self performSelector:@selector(_outroMe) withObject:nil afterDelay:0.2];
}

-(void)_goSubscribe {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		
	} else {
		ASIFormDataRequest *subscribeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[subscribeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[subscribeRequest setDelegate:self];
		[subscribeRequest startAsynchronous];
		
		[_subscribeBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
		[_subscribeBtn removeTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		[_subscribeBtn addTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"Following Topic" action:_vo.list_name label:nil value:-1 withError:&error])
			NSLog(@"error in trackEvent");
	}
}

-(void)_goUnsubscribe {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
		
	} else {
		ASIFormDataRequest *subscribeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Lists.php"]]];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
		[subscribeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[subscribeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[subscribeRequest setDelegate:self];
		[subscribeRequest startAsynchronous];
		
		[_subscribeBtn setTitle:@"Follow Topic" forState:UIControlStateNormal];
		[_subscribeBtn removeTarget:self action:@selector(_goUnsubscribe) forControlEvents:UIControlEventTouchUpInside];
		[_subscribeBtn addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"Unfollowed Topic" action:_vo.list_name label:nil value:-1 withError:&error])
			NSLog(@"error in trackEvent");
	}
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

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNListCardView_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SUBSCRIBED_LIST" object:nil];
}

@end
