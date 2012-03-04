//
//  SNViewController_Airplay.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNVideoPlayerView_Airplay.h"

#import "SNGadgetsView_Airplay.h"
#import "MBProgressHUD.h"
#import "EGOImageView.h"

@interface SNViewController_Airplay : UIViewController {
	SNVideoPlayerView_Airplay *_videoPlayerView;

	SNGadgetsView_Airplay *_gadgetsView;
	MBProgressHUD *_hud;
	EGOImageView *_bufferingImgView;
	
	UIImageView *_hdLogoImgView;
}

-(id)initWithFrame:(CGRect)frame;
@end
