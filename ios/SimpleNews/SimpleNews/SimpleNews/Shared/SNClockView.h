//
//  SNClockView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.28.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNClockView : UIView {
	NSTimer *_timer;
	UILabel *_label;
}


-(id)initAtPosition:(CGPoint)pos;

@end
