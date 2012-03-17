//
//  SNFollowerGridHeaderView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNFollowerGridHeaderView_iPhone : UIView <UITextFieldDelegate> {
	
	UIImageView *_cursorImgView;
	
	UITextField *_txtField;
	UILabel *_txtLabel;
	
	UIButton *_backButton;
}

@end
