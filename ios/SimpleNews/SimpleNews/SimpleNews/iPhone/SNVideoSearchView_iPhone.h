//
//  SNVideoSearchView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNVideoSearchView_iPhone : UIView <UITextFieldDelegate> {
	UITextField *_txtField;
}

-(void)showMe;
-(void)hideMe;

@end
