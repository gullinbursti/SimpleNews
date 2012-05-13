//
//  SNProfileFollowingListViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNListVO.h"

@interface SNProfileFollowingListViewCell_iPhone : UITableViewCell {
	UILabel *_titleLabel;
}

+(NSString *)cellReuseIdentifier;
@property(nonatomic, retain) SNListVO *listVO;

@end
