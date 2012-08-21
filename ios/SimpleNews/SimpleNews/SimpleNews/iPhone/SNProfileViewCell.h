//
//  SNProfileViewCell.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNProfileVO.h"

@interface SNProfileViewCell : UITableViewCell {
	UILabel *_titleLabel;
	BOOL _isHeaderCellType;
}

-(id)init;

+(NSString *)cellReuseIdentifier;
@property(nonatomic, retain) SNProfileVO *profileVO;
@property(nonatomic, retain) UIView *overlayView;


@end
