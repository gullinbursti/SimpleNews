//
//  SNArticleCommentView.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNCommentVO.h"

@interface SNArticleCommentView : UIView {
	SNCommentVO *_vo;
	int _listID;
	
	UILabel *_twitterNameLabel;
	UILabel *_timeLabel;
	UILabel *_twitterBlurbLabel;
}

-(id)initWithFrame:(CGRect)frame commentVO:(SNCommentVO *)vo;


@end
