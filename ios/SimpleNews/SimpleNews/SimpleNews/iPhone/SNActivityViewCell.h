//
//  SNActivityViewCell.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 08.23.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNArticleVO.h"
#import "MBLAsyncResource.h"

@interface SNActivityViewCell : UITableViewCell {
	UIImageView *_activeBGImgView;
	UIImageView *_imgView;
	UILabel *_nameLabel;
}

+(NSString *)cellReuseIdentifier;

- (void)tapped;

@property(nonatomic, retain) SNArticleVO *articleVO;
@end
