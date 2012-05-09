//
//  SNArticleItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"
#import "EGOImageView.h"

#import "ASIFormDataRequest.h"

@interface SNArticleItemView_iPhone : UIView <ASIHTTPRequestDelegate, EGOImageViewDelegate> {
	SNArticleVO *_vo;
	UIButton *_videoButton;
	UIButton *_likeButton;
	EGOImageView *_articleImgView;
	EGOImageView *_videoImgView;
	UILabel *_likesLabel;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end
