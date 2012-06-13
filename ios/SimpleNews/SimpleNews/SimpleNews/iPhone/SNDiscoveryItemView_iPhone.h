//
//  SNDiscoveryItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNArticleVO.h"
#import "MBLResourceLoader.h"
#import "EGOImageView.h"

@interface SNDiscoveryItemView_iPhone : UIView <EGOImageViewDelegate> {
	SNArticleVO *_vo;
	UIImageView *_articleImgView;
	UIButton *_likeButton;
	UIButton *_commentButton;
	UIButton *_videoButton;
	
	EGOImageView *_videoImgView;
}

- (id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end
