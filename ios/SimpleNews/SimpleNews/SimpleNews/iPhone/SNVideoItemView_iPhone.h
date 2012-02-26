//
//  SNVideoItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoItemVO.h"
#import "EGOImageView.h"

@interface SNVideoItemView_iPhone : UIView <UIGestureRecognizerDelegate> {
	EGOImageView *_imageView;
	UILabel *_titleLabel;
	UILabel *_infoLabel;
	
	SNVideoItemVO *_vo;
}

-(id)initWithFrame:(CGRect)frame videoItemVO:(SNVideoItemVO *)vo;

@property (nonatomic, retain) SNVideoItemVO *vo;

@end
