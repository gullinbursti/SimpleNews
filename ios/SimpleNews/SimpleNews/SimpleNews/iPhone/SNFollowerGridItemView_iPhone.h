//
//  SNFollowerGridItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBaseFollowerGridItemView_iPhone.h"
#import "SNFollowerVO.h"
#import "EGOImageView.h"

@interface SNFollowerGridItemView_iPhone : SNBaseFollowerGridItemView_iPhone {
	EGOImageView *_imageView;
}

-(id)initWithFrame:(CGRect)frame followerVO:(SNFollowerVO *)vo;

@end
