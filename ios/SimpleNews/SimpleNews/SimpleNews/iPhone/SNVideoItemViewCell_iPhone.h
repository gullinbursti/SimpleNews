//
//  SNVideoItemViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGOImageView.h"
#import "SNVideoItemVO.h"

@interface SNVideoItemViewCell_iPhone : UITableViewCell {
	EGOImageView *_imgView;
	SNVideoItemVO *_vo;
	
	UIView *_overlayView;
}
+(NSString *)cellReuseIdentifier;

@property(nonatomic) BOOL shouldDrawSeparator;
@property(nonatomic, retain) SNVideoItemVO *vo;

@end
