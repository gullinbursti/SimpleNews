//
//  SNRootOtherViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNRootOtherViewCell_iPhone : UITableViewCell {
	UILabel *_nameLabel;
}

+(NSString *)cellReuseIdentifier;
- (id)initWithTitle:(NSString *)title;

@property(nonatomic, retain) UIView *overlayView;

@end
