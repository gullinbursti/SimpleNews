//
//  SNProfileArticleViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNArticleVO.h"

@interface SNProfileArticleViewCell_iPhone : UITableViewCell {
	UILabel *_titleLabel;
	UILabel *_sourceLabel;
}

+(NSString *)cellReuseIdentifier;

@property (nonatomic, retain) SNArticleVO *articleVO;

@end
