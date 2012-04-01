//
//  SNRecentInfluencersView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "SNBaseInfluencerGridItemView_iPhone.h"

@interface SNRecentInfluencersView_iPhone : SNBaseInfluencerGridItemView_iPhone {
	NSArray *_urls;
	int _cnt;
	
	EGOImageView *_thumb1ImgView;
	EGOImageView *_thumb2ImgView;
	EGOImageView *_thumb3ImgView;
	EGOImageView *_thumb4ImgView;
}

-(id)initWithFrame:(CGRect)frame avatarURLs:(NSArray *)urls;

@end
