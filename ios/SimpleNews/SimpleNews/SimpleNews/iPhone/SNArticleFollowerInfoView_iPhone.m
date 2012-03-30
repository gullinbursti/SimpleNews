//
//  SNArticleFollowerInfoView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.23.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleFollowerInfoView_iPhone.h"

#import "SNAppDelegate.h"
#import "EGOImageView.h"

@implementation SNArticleFollowerInfoView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		EGOImageView *avatarImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 40.0, 40.0)] autorelease];
		avatarImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[self addSubview:avatarImgView];
		
		UILabel *twitterName = [[[UILabel alloc] initWithFrame:CGRectMake(62.0, 13.0, 256.0, 20.0)] autorelease];
		twitterName.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		twitterName.textColor = [UIColor whiteColor];
		twitterName.backgroundColor = [UIColor clearColor];
		twitterName.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		twitterName.shadowOffset = CGSizeMake(1.0, 1.0);
		twitterName.text = _vo.twitterName;
		[self addSubview:twitterName];
		
		NSString *timeSince = @"";
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			timeSince = [NSString stringWithFormat:@"%dd ago", days];
			
		} else {
			if (hours > 0)
				timeSince = [NSString stringWithFormat:@"%dh ago", hours];
			
			else
				timeSince = [NSString stringWithFormat:@"%dm ago", mins];
		}
		
		UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(62.0, 32.0, 41.0, 16.0)] autorelease];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
		dateLabel.textColor = [UIColor colorWithWhite:0.329 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		dateLabel.text = timeSince;
		dateLabel.numberOfLines = 0;
		[self addSubview:dateLabel];
		
		UIButton *twitterButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		twitterButton.frame = CGRectMake(0.0, 0.0, 280.0, self.frame.size.height);
		[twitterButton addTarget:self action:@selector(_goTwitterPage) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:twitterButton];
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];
}


#pragma mark - Navigation
-(void)_goTwitterPage {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", _vo.twitterHandle]];
}

@end
