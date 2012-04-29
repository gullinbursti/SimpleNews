//
//  SNInfluencerListViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNInfluencerVO.h"

#import "EGOImageView.h"

@interface SNInfluencerListViewCell_iPhone : UITableViewCell {
	EGOImageView *_avatarImgView;
	UILabel *_twitterNameLabel;
	UILabel *_twitterBlurbLabel;
	UIImageView *_verifiedIcoImgView;
}

+(NSString *)cellReuseIdentifier;

-(id)initFromList;

@property(nonatomic, retain) SNInfluencerVO *influencerVO;

@end
