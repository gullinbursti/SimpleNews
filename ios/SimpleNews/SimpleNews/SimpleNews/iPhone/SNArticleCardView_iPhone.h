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

@interface SNArticleCardView_iPhone : SNBaseArticleCardView_iPhone <UIScrollViewDelegate, EGOImageViewDelegate> {
	SNArticleVO *_vo;
	
	UIView *_headerView;
	UIView *_headerBgView;
	UIScrollView *_scrollView;
	
	UIImageView *_twitterImgView;
	UIImageView *_playImgView;
	
	UIButton *_playButton;
	CGSize _tweetSize;
	CGSize _titleSize;
	CGSize _contentSize;
	
	UIView *_indicatorView;
	NSMutableArray *_tweets;
	
	BOOL _isExpanded;
	BOOL _isAtTop;
	int _ind;
	
	UIButton *_expandCollapseButton;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo index:(int)idx;
-(void)setTweets:(NSMutableArray *)tweets;

@end
