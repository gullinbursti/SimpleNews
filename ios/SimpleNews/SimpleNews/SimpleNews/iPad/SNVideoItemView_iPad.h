//
//  SNVideoItemView_iPad.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoItemVO.h"
#import "EGOImageView.h"

@interface SNVideoItemView_iPad : UIView {
	SNVideoItemVO *_vo;
	EGOImageView *_imageView;
}

-(id)initWithFrame:(CGRect)frame videoItemVO:(SNVideoItemVO *)vo;

@end
