//
//  SNVideoPlayerView_Airplay.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SNVideoPlayerView_Airplay : UIView {
	MPMoviePlayerController *_playerController;
}

-(void)togglePlayback:(BOOL)isPlaying;

@end
