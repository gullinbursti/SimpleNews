//
//  SNTwitterFriendViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "SNTwitterUserVO.h"

@interface SNTwitterFriendViewCell_iPhone : UITableViewCell {
	EGOImageView *_avatarImgView;
	UILabel *_handleLabel;
	UILabel *_nameLabel;
}

+(NSString *)cellReuseIdentifier;

@property (nonatomic, retain) SNTwitterUserVO *twitterUserVO;

@end
