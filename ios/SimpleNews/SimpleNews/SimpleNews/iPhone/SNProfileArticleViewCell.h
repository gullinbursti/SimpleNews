//
//  SNProfileArticleViewCell.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNArticleVO.h"

@interface SNProfileArticleViewCell : UITableViewCell {
	UILabel *_titleLabel;
	UILabel *_sourceLabel;
}

+(NSString *)cellReuseIdentifier;

@property (nonatomic, retain) SNArticleVO *articleVO;

@end
