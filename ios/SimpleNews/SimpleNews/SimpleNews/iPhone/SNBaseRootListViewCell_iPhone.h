//
//  SNBaseRootListViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNListVO.h"


@interface SNBaseRootListViewCell_iPhone : UITableViewCell {
	UILabel *_nameLabel;
	UIButton *_followButton;
}

+(NSString *)cellReuseIdentifier;

@property(nonatomic, retain) SNListVO *listVO;

@end
