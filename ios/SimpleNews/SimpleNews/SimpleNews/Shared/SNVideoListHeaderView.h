//
//  SNVideoListHeaderView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.29.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoItemVO.h"
#import "EGOImageView.h"

@interface SNVideoListHeaderView : UIView {
	EGOImageView *_imageView;
	UILabel *_titleLabel;
	SNVideoItemVO *_vo;
}

@property (nonatomic, retain) SNVideoItemVO *vo;

@end
