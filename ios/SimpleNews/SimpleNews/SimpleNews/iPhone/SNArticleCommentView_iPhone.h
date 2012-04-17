//
//  SNArticleCommentView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNCommentVO.h"
#import "EGOImageView.h"

@interface SNArticleCommentView_iPhone : UIView {
	SNCommentVO *_vo;
	int _listID;
	
	EGOImageView *_avatarImgView;
	UILabel *_twitterNameLabel;
	UILabel *_timeLabel;
	UILabel *_twitterBlurbLabel;
}

-(id)initWithFrame:(CGRect)frame commentVO:(SNCommentVO *)vo listID:(int)list_id;


@end
