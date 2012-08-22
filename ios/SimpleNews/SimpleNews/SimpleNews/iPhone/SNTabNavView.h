//
//  SNTabNavView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.21.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNTabNavView : UIView {
	UIImageView *imgView;
}

@property (nonatomic, strong) UIButton *feedButton;
@property (nonatomic, strong) UIButton *popularButton;
@property (nonatomic, strong) UIButton *activityButton;
@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) UIButton *composeButton;

@end
