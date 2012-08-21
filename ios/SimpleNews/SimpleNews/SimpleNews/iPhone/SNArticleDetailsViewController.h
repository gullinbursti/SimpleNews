//
//  SNArticleDetailsViewController.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ASIFormDataRequest.h"

#import "SNArticleVO.h"
#import "SNArticleVideoPlayerView.h"
#import "SNUnderlinedLabel.h"
#import "MBLResourceLoader.h"

@interface SNArticleDetailsViewController : UIViewController <MFMailComposeViewControllerDelegate, ASIHTTPRequestDelegate> {
	SNArticleVO *_vo;
	SNArticleVideoPlayerView *_videoPlayerView;
	UIImageView *_articleImgView;
	
	UIScrollView *_scrollView;
	UIButton *_likeButton;
	UIButton *_commentButton;
	
	ASIFormDataRequest *_likeRequest;
}

-(id)initWithArticleVO:(SNArticleVO *)vo;

@end
