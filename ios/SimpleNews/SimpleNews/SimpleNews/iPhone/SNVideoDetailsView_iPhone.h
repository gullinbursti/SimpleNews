//
//  SNVideoDetailsView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideoItemVO.h"
#import "EGOImageView.h"

@interface SNVideoDetailsView_iPhone : UIView <UIGestureRecognizerDelegate> {
	UIView *_imageHolderView;
	EGOImageView *_imageView;
	EGOImageView *_channelImageView;
	SNVideoItemVO *_vo;
	
	UIButton *_backButton;
	UIButton *_playPauseButton;
	
	UILabel *_titleLabel;
	
	BOOL _isScrubbing;
	BOOL _isPaused;
	
	NSTimer *_scrubTimer;
}

-(id)initWithFrame:(CGRect)frame;
-(void)changeVideo:(SNVideoItemVO *)vo;

@end
