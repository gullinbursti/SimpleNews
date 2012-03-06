//
//  SNPlayingVideoItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGOImageView.h"
#import "SNVideoItemVO.h"

@interface SNPlayingVideoItemView_iPhone : UIView <UIScrollViewDelegate> {
	
	UILabel *_titleLabel;
	CGSize _titleSize;
	
	UILabel *_infoLabel;
	CGSize _infoSize;
	
	SNVideoItemVO *_vo;
	EGOImageView *_imageView;
	EGOImageView *_channelImageView;
	
	UIScrollView *_scrollView;
}

-(id)initWithFrame:(CGRect)frame withVO:(SNVideoItemVO *)vo;

-(void)fadeInImage;
-(void)fadeOutImage;
-(void)resetScroll;

@end
