//
//  SNVideoListHeaderView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.29.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoItemVO.h"

@interface SNVideoListHeaderView : UIView {
	UILabel *_titleLabel;
	SNVideoItemVO *_vo;
}

@property (nonatomic, retain) SNVideoItemVO *vo;

@end
