//
//  SNVideoItemView_iPad.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoItemView_iPad.h"

@implementation SNVideoItemView_iPad

-(id)initWithFrame:(CGRect)frame videoItemVO:(SNVideoItemVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 200.0)];
		_imageView.alpha = 0.85;
		_imageView.imageURL = [NSURL URLWithString:vo.thumb_url];
		[self addSubview:_imageView];
	}
	
	return (self);
}


@end
