//
//  SNCategoryItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.21.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNCategoryItemVO.h"
#import "SNBaseListItemView_iPhone.h"

@interface SNCategoryItemView_iPhone : SNBaseListItemView_iPhone {
	SNCategoryItemVO *_vo;
}

-(id)initWithFrame:(CGRect)frame withVO:(SNCategoryItemVO *)vo;
-(void)toggleSelected:(BOOL)isSelected;

@end
