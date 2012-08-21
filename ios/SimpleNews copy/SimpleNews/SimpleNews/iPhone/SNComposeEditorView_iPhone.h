//
//  SNComposeEditorView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "EGOImageView.h"
#import "ASIFormDataRequest.h"
#import "SNArticleVO.h"

@interface SNComposeEditorView_iPhone : UIView <UITextViewDelegate, EGOImageViewDelegate, ASIHTTPRequestDelegate> {
	NSDictionary *_fbFriend;
	
	SNArticleVO *_vo;
	
	int _quoteIndex;
	int _stickerIndex;
	BOOL _isQuote;
	
	NSMutableArray *_quoteList;
	NSMutableArray *_stickerList;
	
	UILabel *_quoteLabel;
	UITextView *_quoteTxtView;
	
	UIView *_canvasView;
	UIView *_customQuoteView;
	
	UIButton *_quoteButton;
	UIButton *_stickerButton;
	
	ASIFormDataRequest *_stickerDataRequest;
	EGOImageView *_stickerImgView;
	
	CGPoint _diffPt;
	
	MBProgressHUD *_progressHUD;
}

- (id)initWithFrame:(CGRect)frame withFriend:(NSDictionary *)fbFriend;
- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)img;
- (id)initWithFrame:(CGRect)frame withArticle:(SNArticleVO *)vo;

@end
