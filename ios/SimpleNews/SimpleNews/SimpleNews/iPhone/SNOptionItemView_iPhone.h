//
//  SNOptionItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNOptionVO.h"

@interface SNOptionItemView_iPhone : UIView {
	UIImageView *_checkImageView;
	
	BOOL _isSelected;
	SNOptionVO *_vo;
}

-(id)initWithFrame:(CGRect)frame withVO:(SNOptionVO *)vo;
-(void)toggleSelected:(BOOL)isSelected;
-(void)deselect;

@end
