//
//  SNTestVideoView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.05.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>

@interface SNTestVideoView : UIView {
	
}

-(void)destroy;

@property (nonatomic, retain) MPMoviePlayerController *mpc;

@end
