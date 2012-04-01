//
//  SNBaseInfluencerGridItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNInfluencerVO.h"

@interface SNBaseInfluencerGridItemView_iPhone : UIView {
	UIView *_holderView;
	BOOL _isSelected;
	
	SNInfluencerVO *_vo;
}

@property (nonatomic, retain) SNInfluencerVO *vo;

-(void)toggleSelected:(BOOL)isSelected;
-(void)fadeTo:(float)opac;

@end
