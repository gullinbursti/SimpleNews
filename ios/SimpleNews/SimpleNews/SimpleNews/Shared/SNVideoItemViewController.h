//
//  SNVideoItemViewController.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SNVideoItemVO.h"
#import "EGOImageView.h"

@interface SNVideoItemViewController : UIViewController {
	MPMoviePlayerController *_playerController;
	
	EGOImageView *_imageView;
	UILabel *_titleLabel;
	
	SNVideoItemVO *_vo;
}

-(id)initWithVO:(SNVideoItemVO *)vo;
-(void)togglePlayback:(BOOL)isPlaying;

@end
