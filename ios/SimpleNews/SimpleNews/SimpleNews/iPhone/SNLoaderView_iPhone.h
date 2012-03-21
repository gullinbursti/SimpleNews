//
//  SNLoaderView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNLoaderView_iPhone : UIView {
	UIImageView *_stripsImgView;
	UIImageView *_highlightImgView;
	UIView *_bgView;
	
	NSTimer *_timer;
}

@property (nonatomic) BOOL isLoading;

-(void)introMe;
-(void)outroMe;

@end
