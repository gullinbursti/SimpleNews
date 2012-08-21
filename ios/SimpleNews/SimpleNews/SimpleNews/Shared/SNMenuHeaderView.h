//
//  SNListHeaderView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.18.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface SNMenuHeaderView : UIView {
	EGOImageView *_imgView;
	UILabel *_label;
}

@property (nonatomic, retain) UIButton *btn;

@end
