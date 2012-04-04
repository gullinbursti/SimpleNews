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

#import "SNBaseArticleCardView_iPhone.h"

@interface SNArticleCardView_iPhone : SNBaseArticleCardView_iPhone <UIScrollViewDelegate, EGOImageViewDelegate, UITextFieldDelegate> {
	NSMutableArray *_tweets;
	NSMutableArray *_reactionViews;
	SNArticleVO *_vo;
	
	CGSize _tweetSize;
	CGSize _titleSize;
	CGSize _contentSize;
	
	UIButton *_playButton;
	UIScrollView *_scrollView;
	UIView *_iconsCoverView;
	
	UIView *_headerBgView;
	UIButton *_collapseButton;
	
	BOOL _isExpanded;
	int _ind;
	
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo index:(int)idx;
-(void)setTweets:(NSMutableArray *)tweets;

@end
