//
//  SNInfluencerGridItemView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.06.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBaseInfluencerGridItemView_iPhone.h"
#import "SNInfluencerVO.h"
#import "EGOImageView.h"

@interface SNInfluencerGridItemView_iPhone : SNBaseInfluencerGridItemView_iPhone {
	EGOImageView *_imageView;
}

-(id)initWithFrame:(CGRect)frame influencerVO:(SNInfluencerVO *)vo;

@end
