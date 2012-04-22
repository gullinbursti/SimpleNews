//
//  SNListCardView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNBaseListCardView_iPhone.h"
#import "SNListVO.h"
#import "SNInfluencersListView.h"
#import "ASIFormDataRequest.h"

@interface SNListCardView_iPhone : SNBaseListCardView_iPhone <ASIHTTPRequestDelegate> {
	SNListVO *_vo;
	UIImageView *_testImgView;
	
	SNInfluencersListView *_influencersListView;
	BOOL _isFlipped;
	
	UIButton *_doneButton;
	UIButton *_flipBtn;
	UIButton *_articlesButton;
	UIButton *_subscribeBtn;
}

-(id)initWithFrame:(CGRect)frame listVO:(SNListVO *)vo;

@end
