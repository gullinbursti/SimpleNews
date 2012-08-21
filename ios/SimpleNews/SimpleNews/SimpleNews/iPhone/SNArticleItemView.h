//
//  SNArticleItemView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.13.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"
#import "EGOImageView.h"
#import "MBLResourceLoader.h"
#import "ASIFormDataRequest.h"

@interface SNArticleItemView : UIView <ASIHTTPRequestDelegate, EGOImageViewDelegate> {
	UIButton *_likeButton;
	UIButton *_videoButton;
	UIButton *_commentButton;
	
	UIImageView *_article1ImgView;
	UIImageView *_article2ImgView;
	EGOImageView *_videoImgView;
	
	SNArticleVO *_vo;
	ASIFormDataRequest *_likeRequest;
	
	BOOL _isFullscreenDblTap;
	NSTimer *_dblTapTimer;
}

@property (nonatomic)BOOL isFirstAppearance;

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end
