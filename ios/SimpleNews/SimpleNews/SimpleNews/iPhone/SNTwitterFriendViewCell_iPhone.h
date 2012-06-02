//
//  SNTwitterFriendViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTwitterUserVO.h"

@interface SNTwitterFriendViewCell_iPhone : UITableViewCell {
	UILabel *_handleLabel;
	UILabel *_nameLabel;
	
	UIImageView *_bgImgView;
}

+(NSString *)cellReuseIdentifier;

@property (nonatomic, retain) SNTwitterUserVO *twitterUserVO;

- (id)initAsHeader;
- (id)initAsMiddle;
- (id)initAsFooter;

@end
