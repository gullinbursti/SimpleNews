//
//  SNArticleItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"
#import "SNArticleVideoPlayerView_iPhone.h"

@interface SNArticleItemView_iPhone : UIView {
	SNArticleVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	UIButton *_videoButton;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end