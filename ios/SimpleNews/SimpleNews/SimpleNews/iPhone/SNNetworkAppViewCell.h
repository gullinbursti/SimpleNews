//
//  SNNetworkAppViewCell.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBaseRootViewCell.h"
#import "SNTopicVO.h"
#import "SNNetworkAppVO.h"

#import "MBLAsyncResource.h"

@interface SNNetworkAppViewCell : SNBaseRootViewCell {
	UIButton *_followButton;
	UIImageView *_imgView;
}

@property(nonatomic, retain) SNNetworkAppVO *networkAppVO;

@end
