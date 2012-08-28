//
//  SNArticleCommentView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.16.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "SNArticleCommentView.h"
#import "SNAppDelegate.h"
#import "SNTwitterAvatarView.h"

@implementation SNArticleCommentView

-(id)initWithFrame:(CGRect)frame commentVO:(SNCommentVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(10.0, 13.0) imageURL:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [[SNAppDelegate fbProfileForUser] objectForKey:@"id"]] handle:[[SNAppDelegate fbProfileForUser] objectForKey:@"username"]];
		[self addSubview:avatarImgView];
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43.0, 12.0, 269.0, frame.size.height)];
		UIImage *img = [UIImage imageNamed:@"chatBubbleBG.png"];
		bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:24.0];
		[self addSubview:bgImgView];
		
		CGSize size = [[NSString stringWithFormat:@"@%@  ", _vo.handle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10] constrainedToSize:CGSizeMake(256.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		UILabel *twitterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56.0, 18.0, 256.0, 14.0)];
		twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
		twitterNameLabel.textColor = [SNAppDelegate snLinkColor];
		twitterNameLabel.backgroundColor = [UIColor clearColor];
		twitterNameLabel.text = [[SNAppDelegate fbProfileForUser] objectForKey:@"name"];
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

		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0, 21.0, 3.0, 10.0)];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
		dateLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textAlignment = UITextAlignmentRight;
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		size = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(56.0, 36.0, 250.0, size.height)];
		contentLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11];
		contentLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		contentLabel.numberOfLines = 0;
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.text = _vo.content;
		[self addSubview:contentLabel];
		
		UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		twitterButton.frame = bgImgView.frame;
		[twitterButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:twitterButton];
	}
	
	return (self);
}

-(void)dealloc {
}


- (void)_goTwitterProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:_vo.handle];
}


@end
