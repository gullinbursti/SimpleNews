//
//  SNDiscoveryArticleCardView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.05.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "EGOImageView.h"

#import "ASIFormDataRequest.h"

@interface SNDiscoveryArticleCardView_iPhone : UIView <ASIHTTPRequestDelegate, EGOImageViewDelegate> {
	SNArticleVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	UIButton *_videoButton;
	UIButton *_likeButton;
	EGOImageView *_articleImgView;
	UILabel *_likesLabel;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;
@end
