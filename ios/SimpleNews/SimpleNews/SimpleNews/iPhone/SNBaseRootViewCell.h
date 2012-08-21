//
//  SNBaseRootViewCell.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.18.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNBaseRootViewCell : UITableViewCell {
	UILabel *_nameLabel;
	UIImageView *_activeBGImgView;
}

+(NSString *)cellReuseIdentifier;

- (id)initWithTitle:(NSString *)title;
- (void)tapped;

@end
