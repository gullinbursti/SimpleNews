//
//  SNBaseFollowerGridItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNFollowerVO.h"

@interface SNBaseFollowerGridItemView_iPhone : UIView {
	UIView *_holderView;
	BOOL _isSelected;
	
	SNFollowerVO *_vo;
}

@property (nonatomic, retain) SNFollowerVO *vo;

-(void)toggleSelected:(BOOL)isSelected;
-(void)fadeTo:(float)opac;

@end
