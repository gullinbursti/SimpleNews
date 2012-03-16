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

@interface SNArticleCardView_iPhone : UIView <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, EGOImageViewDelegate> {
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
	
	UIView *_holderView;
	UIImageView *_scaledImgView;
	
	UIButton *_playButton;
	CGSize _tweetSize;
	CGSize _contentSize;
}

@property (nonatomic, retain) UIView *holderView;
@property (nonatomic, retain) UIImageView *scaledImgView;

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo;

@end
