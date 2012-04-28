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
#import "SNArticleOptionsView_iPhone.h"
#import "SNUnderlinedLabel.h"

#import "SNShareSheetView_iPhone.h"

@interface SNArticleDetailsViewController_iPhone : UIViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate> {
	SNArticleVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	SNArticleOptionsView_iPhone *_articleOptionsView;
	
	UIScrollView *_scrollView;
	UIWebView *_webView;
	UILabel *_titleLabel;
	UILabel *_dateLabel;
	UIImageView *_toggleLtImgView;
	UIImageView *_toggleRtImgView;
	
	UIButton *_viewOptionsButton;
	BOOL _isOptions;
	BOOL _isTextView;
	
	SNShareSheetView_iPhone *_shareSheetView;
	UIView *_blackMatteView;
}

-(id)initWithArticleVO:(SNArticleVO *)vo;

@end
