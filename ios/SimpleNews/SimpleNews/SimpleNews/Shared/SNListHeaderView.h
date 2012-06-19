//
//  SNListHeaderView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.18.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface SNListHeaderView : UIView {
	EGOImageView *_imgView;
	UILabel *_label;
}

@property (nonatomic, retain) UIButton *btn;

@end
