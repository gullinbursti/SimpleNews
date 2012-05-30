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

-(id)initWithFrame:(CGRect)frame commentVO:(SNCommentVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, frame.size.height)];
		UIImage *img = [UIImage imageNamed:@"profileBackground.png"];
		bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
		[self addSubview:bgImgView];
		
		EGOImageView *avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 19.0, 25.0, 25.0)];
		avatarImgView.imageURL = [NSURL URLWithString:_vo.avatarURL];
		[self addSubview:avatarImgView];
		
		UILabel *twitterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 17.0, 256.0, 14.0)];
		twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		twitterNameLabel.textColor = [SNAppDelegate snLinkColor];
		twitterNameLabel.backgroundColor = [UIColor clearColor];
		twitterNameLabel.text = [NSString stringWithFormat:@"@%@", _vo.handle];
		[self addSubview:twitterNameLabel];
		
		CGSize size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11] constrainedToSize:CGSizeMake(256.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 30.0, 256.0, size.height)];
		contentLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11];
		contentLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		contentLabel.numberOfLines = 0;
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.text = _vo.content;
		[self addSubview:contentLabel];
		
		
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
		
		int offset = 0;
		if (_vo.isLiked) {
			UIImageView *likeIcoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(45.0, size.height + 23.0, 24.0, 24.0)];
			likeIcoImgView.image = [UIImage imageNamed:@"heartCommentsIcon.png"];
			[self addSubview:likeIcoImgView];
			offset = 15;
		}
		
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0 + offset, size.height + 32.0, 100.0, 8.0)];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:8];
		dateLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textAlignment = UITextAlignmentLeft;
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
	}
	
	return (self);
}

-(void)dealloc {
}



@end
