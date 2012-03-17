//
//  SNFollowerInfoView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

#import "SNFollowerVO.h"

@interface SNFollowerInfoView : UIView {
	UILabel *_nameLabel;
	UILabel *_infoLabel;
	
	EGOImageView *_avatarImgView;
	SNFollowerVO *_vo;
	
	UIButton *_queueButton;
	UIButton *_watchButton;
	
	UIImageView *_bgImgView;
}

-(id)initWithFrame:(CGRect)frame followerVO:(SNFollowerVO *)vo;

@end
