//
//  SNPluginItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.27.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNBaseListItemView_iPhone.h"

#import "SNPluginVO.h"

@interface SNPluginItemView_iPhone : SNBaseListItemView_iPhone {
	SNPluginVO *_vo;
	
}

-(id)initWithFrame:(CGRect)frame withVO:(SNPluginVO *)vo;
-(void)toggleSelected:(BOOL)isSelected;

@end
