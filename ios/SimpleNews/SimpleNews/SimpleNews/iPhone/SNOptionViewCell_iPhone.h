//
//  SNOptionViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNOptionVO.h"

@interface SNOptionViewCell_iPhone : UITableViewCell {
	UILabel *_titleLabel;
}


+(NSString *)cellReuseIdentifier;
@property(nonatomic, retain) SNOptionVO *optionVO;


@end
