//
//  SNArticleOptionsView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNArticleOptionsView_iPhone : UIView <UIGestureRecognizerDelegate> {
	
	UIImageView *_sizeIndicatorImgView;
	UIButton *_brightnessButton;
	
	BOOL _isRevealed;
	
	int _fontSize;
	BOOL _isDark;
}


@end
