//
//  SNArticleDetailsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ASIFormDataRequest.h"

#import "SNArticleVO.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNUnderlinedLabel.h"
#import "MBLResourceLoader.h"

@interface SNArticleDetailsViewController_iPhone : UIViewController <MFMailComposeViewControllerDelegate, ASIHTTPRequestDelegate> {
	SNArticleVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	UIImageView *_articleImgView;
	
	UIScrollView *_scrollView;
	UIButton *_likeButton;
	UIButton *_commentButton;
	
	ASIFormDataRequest *_likeRequest;
}

-(id)initWithArticleVO:(SNArticleVO *)vo;

@end
