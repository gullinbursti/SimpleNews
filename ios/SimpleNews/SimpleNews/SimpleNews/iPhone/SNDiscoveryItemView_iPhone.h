//
//  SNDiscoveryItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBLPageItemViewController.h"

#import "SNArticleVO.h"
#import "MBLResourceLoader.h"
#import "EGOImageView.h"
#import "ASIFormDataRequest.h"

@interface SNDiscoveryItemView_iPhone : MBLPageItemViewController <EGOImageViewDelegate, ASIHTTPRequestDelegate> {
	UIImageView *_backgroundImageView;
	UIView *_mainImageHolderView;
	
	UILabel *_titleLabel;
	NSArray *_attributionViews;
	NSArray *_twitterAvatars;
	
	UIImageView *_articleImgView;
	UIView *_sub1ImgHolderView;
	UIImageView *_sub1ImgView;
	UIView *_sub2ImgHolderView;
	UIImageView *_sub2ImgView;
	UIButton *_likeButton;
	UIButton *_commentButton;

	// For videos
	UIView *_videoMatteView;
	EGOImageView *_videoImgView;
	UIButton *_videoButton;
}

@end
