//
//  SNVideoSearchView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNVideoSearchView_iPhone : UIView <UITextFieldDelegate> {
	
	UIImageView *_cursorImgView;
	
	UITextField *_txtField;
	UILabel *_txtLabel;
}

@end
