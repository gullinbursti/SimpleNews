//
//  SNArticleCommentViewCell_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNReactionVO.h"

#import "EGOImageView.h"

@interface SNArticleCommentViewCell_iPhone : UITableViewCell {
	EGOImageView *_avatarImgView;
	UILabel *_twitterNameLabel;
	UILabel *_timeLabel;
	UILabel *_twitterBlurbLabel;
}

+(NSString *)cellReuseIdentifier;

@property(nonatomic, retain) SNReactionVO *reactionVO;

@end
