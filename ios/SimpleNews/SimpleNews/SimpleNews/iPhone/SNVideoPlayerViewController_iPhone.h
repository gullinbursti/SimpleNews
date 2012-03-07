//
//  SNVideoPlayerViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SNVideoItemVO.h"

@interface SNVideoPlayerViewController_iPhone : UIViewController {
	
	NSTimer *_timer;
	BOOL _isFinished;
	BOOL _isPaused;
	BOOL _isFirst;
	BOOL _isStalled;
	float _duration;
	
	SNVideoItemVO *_vo;
	
	NSString *_videoURL;
	UIView *_videoHolderView;
}


@property (nonatomic, retain) MPMoviePlayerController *mpc;


@end
