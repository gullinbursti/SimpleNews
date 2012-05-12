//
//  SNArticleCommentView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleCommentView_iPhone.h"
#import "SNAppDelegate.h"
#import "EGOImageView.h"

@implementation SNArticleCommentView_iPhone

-(id)initWithFrame:(CGRect)frame commentVO:(SNCommentVO *)vo listID:(int)list_id {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		_listID = list_id;
		
		EGOImageView *avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 19.0, 25.0, 25.0)];
		avatarImgView.imageURL = [NSURL URLWithString:_vo.thumb_url];
		[self addSubview:avatarImgView];
		
		UILabel *twitterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 17.0, 256.0, 14.0)];
		twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		twitterNameLabel.textColor = [SNAppDelegate snLinkColor];
		twitterNameLabel.backgroundColor = [UIColor clearColor];
		twitterNameLabel.text = [NSString stringWithFormat:@"@%@", _vo.twitterHandle];
		[self addSubview:twitterNameLabel];
		
		CGSize size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11] constrainedToSize:CGSizeMake(256.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		UILabel *twitterBlurbLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 30.0, 256.0, size.height)];
		twitterBlurbLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11];
		twitterBlurbLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		twitterBlurbLabel.numberOfLines = 0;
		twitterBlurbLabel.backgroundColor = [UIColor clearColor];
		twitterBlurbLabel.text = _vo.content;
		[self addSubview:twitterBlurbLabel];
		
		
		NSString *timeSince = @"";
		int secs = [SNAppDelegate secondsAfterDate:_vo.added];
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			timeSince = [NSString stringWithFormat:@"%dD AGO", days];
			
		} else {
			if (hours > 0)
				timeSince = [NSString stringWithFormat:@"%dH AGO", hours];
			
			else {
				if (mins > 0)				
					timeSince = [NSString stringWithFormat:@"%dM AGO", mins];
				
				else
					timeSince = [NSString stringWithFormat:@"%dS AGO", secs];
			}
		}
		
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, size.height + 32.0, 100.0, 8.0)];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:8];
		dateLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textAlignment = UITextAlignmentLeft;
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		
		int offset = 0;
		if (_vo.isLiked) {
			UIImageView *likeIcoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(60.0, size.height + 48.0, 25.0, 25.0)];
			likeIcoImgView.image = [UIImage imageNamed:@"smallDoneButton_nonActive.png"];
			[self addSubview:likeIcoImgView];
			offset = 30.0;
		}
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, offset + size.height + 55.0, self.frame.size.width - 40.0, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:1.0 topCapHeight:2.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

-(void)dealloc {
}



@end
