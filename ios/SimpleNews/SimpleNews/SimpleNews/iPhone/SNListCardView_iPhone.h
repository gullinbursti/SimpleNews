//
//  SNListCardView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNListVO.h"
#import "SNInfluencersListView.h"
#import "EGOImageView.h"
#import "SNListInfoView_iPhone.h"

@interface SNListCardView_iPhone : UIView {
	SNListVO *_vo;
	UIImageView *_testImgView;
	EGOImageView *_coverImgView;
	
	SNInfluencersListView *_influencersListView;
	SNListInfoView_iPhone *_listInfoView;
	BOOL _isFlipped;
	
	UIButton *_subscribeBtn;
	UIButton *_articlesButton;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;

@end
