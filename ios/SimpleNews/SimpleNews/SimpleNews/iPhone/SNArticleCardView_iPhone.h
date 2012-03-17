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
	
	EGOImageView *_avatarImgView;
	EGOImageView *_bgImageView;
	
	UILabel *_twitterName;
	UILabel *_tweetLabel;
	UILabel *_dateLabel;
	UILabel *_contentLabel;
	UIImageView *_twitterImgView;
	UIButton *_shareButton;
	
	UITableView *_tableView;
	
	UIButton *_playButton;
	CGSize _tweetSize;
	CGSize _contentSize;
}


-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end
