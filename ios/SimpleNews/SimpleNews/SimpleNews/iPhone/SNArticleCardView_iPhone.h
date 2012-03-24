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

@interface SNArticleCardView_iPhone : SNBaseArticleCardView_iPhone <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, EGOImageViewDelegate> {
	SNArticleVO *_vo;
	
	UIView *_headerView;
	UIView *_headerBgView;
	
	UIImageView *_twitterImgView;
	UIImageView *_playImgView;
	
	UITableView *_tableView;
	
	UIButton *_playButton;
	CGSize _tweetSize;
	CGSize _titleSize;
	CGSize _contentSize;
	
	UIView *_indicatorView;
	
	BOOL _isAtTop;
	int _ind;
}

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo index:(int)idx;

@end
