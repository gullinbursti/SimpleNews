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
#import "MBLResourceLoader.h"
#import "ASIFormDataRequest.h"

@interface SNArticleItemView_iPhone : UIView <ASIHTTPRequestDelegate, EGOImageViewDelegate> {
	UIButton *_likeButton;
	UIButton *_videoButton;
	
	UIImageView *_articleImgView;
	EGOImageView *_videoImgView;
	
	SNArticleVO *_vo;
	ASIFormDataRequest *_likeRequest;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end
