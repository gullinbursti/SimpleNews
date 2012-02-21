//
//  SNViewController_Airplay.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoPlayerView_Airplay.h"

@interface SNViewController_Airplay : UIViewController {
	SNVideoPlayerView_Airplay *_videoPlayerView;
}

-(id)initWithFrame:(CGRect)frame;
@end
