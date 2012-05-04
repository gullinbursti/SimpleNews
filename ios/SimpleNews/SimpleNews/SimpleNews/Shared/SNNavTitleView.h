//
//  SNNavTitleView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNNavTitleView : UIView {
	UILabel *_label;
}

-(id)initWithTitle:(NSString *)title;

@end
