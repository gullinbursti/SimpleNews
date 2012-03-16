//
//  SNFollowerGridItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNFollowerVO.h"
#import "EGOImageView.h"

@interface SNFollowerGridItemView_iPhone : UIView {
	EGOImageView *_imageView;
	SNFollowerVO *_vo;
	
	BOOL _isSelected;
}

-(id)initWithFrame:(CGRect)frame followerVO:(SNFollowerVO *)vo;
-(void)toggleSelected:(BOOL)isSelected;
-(void)fadeTo:(float)opac;

@property (nonatomic, retain) SNFollowerVO *vo;

@end
