//
//  SNArticleDetailsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "SNArticleVO.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNUnderlinedLabel.h"

@interface SNArticleDetailsViewController_iPhone : UIViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate, UIActionSheetDelegate, EGOImageViewDelegate> {
	SNArticleVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	
	UIScrollView *_scrollView;
	UIImageView *_toggleLtImgView;
	UIImageView *_toggleRtImgView;
	
	UIButton *_likeButton;
}

-(id)initWithArticleVO:(SNArticleVO *)vo;

@end
