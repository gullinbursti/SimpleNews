//
//  SNArticleCardView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"
#import "EGOImageView.h"

@interface SNArticleCardView_iPhone : UIView {
	SNArticleVO *_vo;
	
	UIView *_contentHolderView;
	EGOImageView *_avatarImgView;
	EGOImageView *_bgImageView;
	
	UILabel *_twitterName;
	UILabel *_tweetLabel;
	UILabel *_dateLabel;
	UIImageView *_twitterImgView;
	UIButton *_shareButton;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end
