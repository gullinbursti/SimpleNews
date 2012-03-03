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

@interface SNPlayingVideoItemView_iPhone : UIView {
	EGOImageView *_imageView;
	UILabel *_titleLabel;
	SNVideoItemVO *_vo;
	EGOImageView *_channelImageView;
	CGSize _textSize;
}

-(id)initWithFrame:(CGRect)frame withVO:(SNVideoItemVO *)vo;
-(void)introMe;
-(void)outroMe;

@end
