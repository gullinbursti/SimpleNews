//
//  SNArticleCommentView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "SNArticleCommentView_iPhone.h"
#import "SNAppDelegate.h"
#import "EGOImageView.h"

@implementation SNArticleCommentView_iPhone

-(id)initWithFrame:(CGRect)frame commentVO:(SNCommentVO *)vo listID:(int)list_id {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		_listID = list_id;
		
		EGOImageView *avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 40.0, 40.0)];
		avatarImgView.layer.cornerRadius = 8.0;
		avatarImgView.clipsToBounds = YES;
		avatarImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		avatarImgView.layer.borderWidth = 1.0;
		avatarImgView.imageURL = [NSURL URLWithString:_vo.thumb_url];
		[self addSubview:avatarImgView];
		
		UILabel *twitterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 16.0, 256.0, 20.0)];
		twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		twitterNameLabel.textColor = [UIColor blackColor];
		twitterNameLabel.backgroundColor = [UIColor clearColor];
		twitterNameLabel.text = _vo.twitterName;
		[self addSubview:twitterNameLabel];
		
		NSString *timeSince = @"";
		int secs = [SNAppDelegate secondsAfterDate:_vo.added];
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			timeSince = [NSString stringWithFormat:@"%dd", days];
			
		} else {
			if (hours > 0)
				timeSince = [NSString stringWithFormat:@"%dh", hours];
			
			else {
				if (mins > 0)				
					timeSince = [NSString stringWithFormat:@"%dm", mins];
				
				else
					timeSince = [NSString stringWithFormat:@"%ds", secs];
			}
		}
		
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(208.0, 16.0, 100.0, 18.0)];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		dateLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textAlignment = UITextAlignmentRight;
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		CGSize size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(256.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		UILabel *twitterBlurbLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 36.0, 256.0, size.height)];
		twitterBlurbLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		twitterBlurbLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		twitterBlurbLabel.numberOfLines = 0;
		twitterBlurbLabel.backgroundColor = [UIColor clearColor];
		twitterBlurbLabel.text = _vo.content;
		[self addSubview:twitterBlurbLabel];
		
		int offset = 0;
		if (_vo.isLiked) {
			UIImageView *likeIcoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(62.0, size.height + 48.0, 25.0, 25.0)];
			likeIcoImgView.image = [UIImage imageNamed:@"smallDoneButton_nonActive.png"];
			[self addSubview:likeIcoImgView];
			offset = 30.0;
		}
		
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, offset + size.height + 48.0, self.frame.size.width, 1.0)];
		[lineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:lineView];	
	}
	
	return (self);
}

-(void)dealloc {
}



@end
