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
#import "ASIFormDataRequest.h"

#import "SNBaseArticleCardView_iPhone.h"

@interface SNArticleCardView_iPhone : SNBaseArticleCardView_iPhone <UIScrollViewDelegate, EGOImageViewDelegate, UITextFieldDelegate, ASIHTTPRequestDelegate> {
	NSMutableArray *_tweets;
	NSMutableArray *_reactionViews;
	SNArticleVO *_vo;
	int _list_id;
	
	//CGSize _tweetSize;
	CGSize _titleSize;
	CGSize _contentSize;
	
	ASIFormDataRequest *_commentSubmitRequest;
	
	UIButton *_playButton;
	UIScrollView *_scrollView;
	UIView *_iconsCoverView;
	UIImageView *_inputBgImgView;
	
	UIView *_headerBgView;
	UIImageView *_commentsBGImgView;
	UITextField *_commentTxtField;
	UILabel *_commentsLabel;
	UIButton *_collapseButton;
	
	BOOL _isExpanded;
	int _ind;
	int _commentsOffset;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo listID:(int)list_id;
-(void)setTweets:(NSMutableArray *)tweets;

@end
