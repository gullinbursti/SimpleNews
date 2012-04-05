//
//  SNListInfoView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNListVO.h"

@interface SNListInfoView_iPhone : UIView {
	SNListVO *_vo;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;

@end
