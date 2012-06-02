//
//  SNArticleCommentsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"
#import "SNArticleVO.h"
#import "EGORefreshTableHeaderView.h"

@interface SNArticleCommentsViewController_iPhone : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate>{
	SNArticleVO *_vo;
	ASIFormDataRequest *_commentSubmitRequest;
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	UIScrollView *_scrollView;
	UIImageView *_scrollBgView;
	UITextField *_commentTxtField;
	UILabel *_commentsLabel;
	UIView *_bgView;
	UIButton *_likeButton;
	
	NSMutableArray *_commentViews;
	
	int _commentOffset;
	BOOL _isLiked;
	BOOL _reloading;
}

-(id)initWithArticleVO:(SNArticleVO *)vo;

@end
