//
//  SNProfileViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNProfileVO.h"

@interface SNProfileViewCell_iPhone : UITableViewCell {
	UILabel *_titleLabel;
	BOOL _isHeaderCellType;
}

-(id)init;

+(NSString *)cellReuseIdentifier;
@property(nonatomic, retain) SNProfileVO *profileVO;
@property(nonatomic, retain) UIView *overlayView;


@end
