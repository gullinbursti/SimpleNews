//
//  SNCategoryItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNCategoryItemVO.h"

@interface SNCategoryItemView_iPhone : UIView {
	SNCategoryItemVO *_vo;
	
	UILabel *_titleLabel;
	UIImageView *_checkImageView;
	
	BOOL _isSelected;
}

-(id)initWithFrame:(CGRect)frame withVO:(SNCategoryItemVO *)vo;
-(void)toggleSelected:(BOOL)isSelected;

@end
