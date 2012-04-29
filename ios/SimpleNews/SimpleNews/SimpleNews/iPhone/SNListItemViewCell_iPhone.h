//
//  SNListItemViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNListVO.h"
#import "EGOImageView.h"
#import "ASIFormDataRequest.h"

@interface SNListItemViewCell_iPhone : UITableViewCell <ASIHTTPRequestDelegate> {
	EGOImageView *_avatarImgView;
	
	UIButton *_followingButton;
	UILabel *_nameLabel;
	UILabel *_curatorsLabel;
}

+(NSString *)cellReuseIdentifier;

@property(nonatomic, retain) SNListVO *listVO;

@end
