//
//  SNListItemViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNListVO.h"
#import "EGOImageView.h"

@interface SNListItemViewCell_iPhone : UITableViewCell {
	EGOImageView *_avatarImgView;
	UILabel *_nameLabel;
	UILabel *_curatorsLabel;
}

+(NSString *)cellReuseIdentifier;

@property(nonatomic, retain) SNListVO *listVO;

@end
