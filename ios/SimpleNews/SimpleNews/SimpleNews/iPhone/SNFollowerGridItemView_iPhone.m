//
//  SNFollowerGridItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNFollowerGridItemView_iPhone.h"
#import "SNAppDelegate.h"

@implementation SNFollowerGridItemView_iPhone

@synthesize vo = _vo;

-(id)initWithFrame:(CGRect)frame followerVO:(SNFollowerVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		_isSelected = NO;
		
		self.clipsToBounds = YES;
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 72.0, 72.0)];
		_imageView.imageURL = [NSURL URLWithString:_vo.avatar_url];
		_imageView.alpha = 1.0;
		[self addSubview:_imageView];
		
		_checkImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 72.0, 72.0)] autorelease];
		_checkImgView.hidden = YES;
		_checkImgView.image = [UIImage imageNamed:@"checkMarkActive.png"];
		[self addSubview:_checkImgView];
	}
	
	return (self);
}

-(void)dealloc {
	_imageView = nil;
	[_vo release];
	[_checkImgView release];
	
	[super dealloc];
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == self) {
		[self toggleSelected:!_isSelected];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FOLLOWER_TAPPED" object:_vo];
		
		return;
	}
}

-(void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	
	if (_isSelected)
		[self fadeTo:1.0];
	
	else
		[self fadeTo:1.0];
	
	
	_checkImgView.hidden = !_isSelected;
}

-(void)fadeTo:(float)opac {
	[UIView animateWithDuration:0.15 animations:^(void) {
		_imageView.alpha = opac;
	}];
}

@end