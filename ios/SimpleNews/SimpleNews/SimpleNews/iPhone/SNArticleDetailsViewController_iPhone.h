//
//  SNArticleDetailsViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.17.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNArticleVO.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNArticleOptionsView_iPhone.h"

@interface SNArticleDetailsViewController_iPhone : UIViewController {
	SNArticleVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	SNArticleOptionsView_iPhone *_articleOptionsView;
	
	UIView *_holderView;
	UIButton *_viewOptionsButton;
	BOOL _isOptions;
}

-(id)initWithArticleVO:(SNArticleVO *)vo;

@end
