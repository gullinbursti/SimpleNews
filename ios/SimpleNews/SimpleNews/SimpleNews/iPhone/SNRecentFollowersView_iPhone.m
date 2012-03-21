//
//  SNRecentFollowersView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNRecentFollowersView_iPhone.h"

@interface SNRecentFollowersView_iPhone()
@end

@implementation SNRecentFollowersView_iPhone
#define kThumbSize 36.0

-(id)initWithFrame:(CGRect)frame avatarURLs:(NSArray *)urls {
	if ((self = [super initWithFrame:frame])) {
		_urls = urls;
		
		_isSelected = YES;
		_holderView.frame = CGRectMake(0.0, 5.0, 80.0, 80.0);
		
		_thumb1ImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, kThumbSize, kThumbSize)];
		_thumb1ImgView.imageURL = [NSURL URLWithString:[_urls objectAtIndex:0]];
		[_holderView addSubview:_thumb1ImgView];
		
		_thumb2ImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0 + kThumbSize, 4.0, kThumbSize, kThumbSize)];
		_thumb2ImgView.imageURL = [NSURL URLWithString:[_urls objectAtIndex:1]];
		[_holderView addSubview:_thumb2ImgView];
		
		_thumb3ImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0, 4.0 + kThumbSize, kThumbSize, kThumbSize)];
		_thumb3ImgView.imageURL = [NSURL URLWithString:[_urls objectAtIndex:2]];
		[_holderView addSubview:_thumb3ImgView];
		
		_thumb4ImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0 + kThumbSize, 4.0 + kThumbSize, kThumbSize, kThumbSize)];
		_thumb4ImgView.imageURL = [NSURL URLWithString:[_urls objectAtIndex:3]];
		[_holderView addSubview:_thumb4ImgView];
		
		[self toggleSelected:YES];
	}
	
	return (self);
}

-(void)dealloc {
	[_urls release];
	
	[_thumb1ImgView release];
	[_thumb2ImgView release];
	[_thumb3ImgView release];
	[_thumb4ImgView release];
	
	[super dealloc];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == _holderView) {
		[self toggleSelected:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECENT_TAPPED" object:_vo];
		
		return;
	}
}

@end
