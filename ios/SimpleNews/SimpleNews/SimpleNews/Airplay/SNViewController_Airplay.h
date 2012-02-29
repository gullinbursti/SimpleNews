//
//  SNViewController_Airplay.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoPlayerView_Airplay.h"
#import "SNLogoView.h"
#import "SNClockView.h"

@interface SNViewController_Airplay : UIViewController {
	SNVideoPlayerView_Airplay *_videoPlayerView;
	
	SNLogoView *_logoView;
	SNClockView *_clockView;
}

-(id)initWithFrame:(CGRect)frame;
@end
