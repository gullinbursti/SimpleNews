//
//  SNListCardView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNListVO.h"

@interface SNListCardView_iPhone : UIView {
	SNListVO *_vo;
	UIImageView *_testImgView;
	
	UIView *_influencersView;
	BOOL _isExpanded;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;

@end
