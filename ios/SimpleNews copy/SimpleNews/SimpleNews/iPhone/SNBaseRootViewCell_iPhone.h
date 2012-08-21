//
//  SNBaseRootViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.18.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNBaseRootViewCell_iPhone : UITableViewCell {
	UILabel *_nameLabel;
	UIImageView *_activeBGImgView;
}

+(NSString *)cellReuseIdentifier;
- (void)tapped;

@end
