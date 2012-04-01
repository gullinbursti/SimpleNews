//
//  SNInfluencerGridItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNInfluencerGridItemView_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNInfluencerGridItemView_iPhone

-(id)initWithFrame:(CGRect)frame influencerVO:(SNInfluencerVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 72.0, 72.0)];
		_imageView.imageURL = [NSURL URLWithString:_vo.avatar_url];
		_imageView.alpha = 1.0;
		[_holderView addSubview:_imageView];
		
		[self toggleSelected:NO];
	}
	
	return (self);
}

-(void)dealloc {
	_imageView = nil;
	[_vo release];
	
	[super dealloc];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSLog(@"TOUCHED:%@", [touch view]);
	
	if ([touch view] == _holderView) {
		[self toggleSelected:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"INFLUENCER_TAPPED" object:_vo];
		
		return;
	}
}

@end