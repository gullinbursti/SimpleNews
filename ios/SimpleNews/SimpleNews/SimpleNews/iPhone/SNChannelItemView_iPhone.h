//
//  SNChannelItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNChannelVO.h"
#import "EGOImageView.h"

@interface SNChannelItemView_iPhone : UIView {
	EGOImageView *_imageView;
	SNChannelVO *_vo;
	UIImageView *_checkImgView;
	
	BOOL _isSelected;
}

-(id)initWithFrame:(CGRect)frame channelVO:(SNChannelVO *)vo;
-(void)toggleSelected:(BOOL)isSelected;
-(void)fadeTo:(float)opac;

@property (nonatomic, retain) SNChannelVO *vo;

@end
