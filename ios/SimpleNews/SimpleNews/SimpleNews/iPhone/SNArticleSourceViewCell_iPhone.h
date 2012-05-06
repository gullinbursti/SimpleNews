//
//  SNArticleSourceViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "SNArticleSourceVO.h"

@interface SNArticleSourceViewCell_iPhone : UITableViewCell {
	UILabel *_nameLabel;
	UIButton *_followButton;
	EGOImageView *_iconImgView;
}

+(NSString *)cellReuseIdentifier;

@property(nonatomic, retain) SNArticleSourceVO *sourceVO;

@end
