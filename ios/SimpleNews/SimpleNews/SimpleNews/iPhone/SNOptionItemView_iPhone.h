//
//  SNOptionItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNBaseListItemView_iPhone.h"

#import "SNOptionVO.h"

@interface SNOptionItemView_iPhone : SNBaseListItemView_iPhone {
	SNOptionVO *_vo;
}

-(id)initWithFrame:(CGRect)frame withVO:(SNOptionVO *)vo;
-(void)toggleSelected:(BOOL)isSelected;

@end
