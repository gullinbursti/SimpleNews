//
//  SNGadgetsView_Airplay.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNWeatherGadgetView_Airplay.h"
#import "SNClockView.h"

@interface SNGadgetsView_Airplay : UIView {
	UIView *_bgView;
	SNClockView *_clockView;
	SNWeatherGadgetView_Airplay *_weatherGadgetView;
}

@end
