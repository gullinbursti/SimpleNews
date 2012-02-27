//
//  SNDeviceItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNBaseListItemView_iPhone.h"
#import "SNDeviceVO.h"

@interface SNDeviceItemView_iPhone : SNBaseListItemView_iPhone {
	SNDeviceVO *_vo;
}

@property (nonatomic, retain) SNDeviceVO *vo;

-(id)initWithFrame:(CGRect)frame withVO:(SNDeviceVO *)vo;
-(void)deselect;

@end
