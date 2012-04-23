//
//  SNArticleCommentsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ASIFormDataRequest.h"
#import "SNArticleVO.h"

@interface SNArticleCommentsViewController_iPhone : UIViewController <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, ASIHTTPRequestDelegate>{
	SNArticleVO *_vo;
	ASIFormDataRequest *_commentSubmitRequest;
	
	UIScrollView *_scrollView;
	UIImageView *_commentsBGImgView;
	UITextField *_commentTxtField;
	UILabel *_commentsLabel;
	UIView *_bgView;
	
	NSMutableArray *_commentViews;
	
	int _list_id;
	int _commentOffset;
	BOOL _isLiked;
}

-(id)initWithArticleVO:(SNArticleVO *)vo listID:(int)listID;

@end
