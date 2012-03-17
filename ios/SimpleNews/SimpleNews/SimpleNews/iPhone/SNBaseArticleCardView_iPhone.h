//
//  SNBaseArticleCardView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNBaseArticleCardView_iPhone : UIView {
	UIView *_holderView;
	UIImageView *_scaledImgView;
	
	UIButton *_gridButton;
}

@property (nonatomic, retain) UIView *holderView;
@property (nonatomic, retain) UIImageView *scaledImgView;


@end
