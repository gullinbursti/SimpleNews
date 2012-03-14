//
//  SNArticleCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleCardView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNArticleCardView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		if (_vo.isDark)
			[self setBackgroundColor:[UIColor blackColor]];
		
		else
			[self setBackgroundColor:[UIColor whiteColor]];
		
		
		_bgImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_bgImageView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
		[self addSubview:_bgImageView];
		
		_shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_shareButton.frame = CGRectMake(272.0, 2.0, 44.0, 44.0);
		
		if (_vo.isDark) {
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActiveWhite.png"] forState:UIControlStateNormal];
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_activeWhite.png"] forState:UIControlStateHighlighted];
		
		} else {
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive.png"] forState:UIControlStateNormal];
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_active.png"] forState:UIControlStateHighlighted];
		}
		
		[_shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_shareButton];
		
		_contentHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 300.0, self.frame.size.width, self.frame.size.height - 300.0)];
		[_contentHolderView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		[self addSubview:_contentHolderView];
		
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 72.0, 72.0)];
		_avatarImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[_contentHolderView addSubview:_avatarImgView];
		
		_twitterName = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 32.0, 256.0, 20.0)];
		_twitterName.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_twitterName.textColor = [UIColor whiteColor];
		_twitterName.backgroundColor = [UIColor clearColor];
		_twitterName.text = _vo.twitterName;
		[_contentHolderView addSubview:_twitterName];
		
		NSString *timeSince;
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			if (days == 1)
				timeSince = @"1 day ago";
			
			else if (days > 1)
				timeSince = [NSString stringWithFormat:@"%d days ago", days];
			
		} else {
			if (hours == 1)
				timeSince = @"1 hour ago";
			
			else if (hours > 1)
				timeSince = [NSString stringWithFormat:@"%d hours ago", hours];
			
			else {
				if (mins == 1)
					timeSince = @"1 minute ago";
				
				else if (mins > 1)
					timeSince = [NSString stringWithFormat:@"%d minutes ago", mins];
			}
		}
		
		_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 32.0, 100.0, 20.0)];
		_dateLabel.textAlignment = UITextAlignmentRight;
		_dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_dateLabel.textColor = [UIColor lightGrayColor];
		_dateLabel.backgroundColor = [UIColor clearColor];
		_dateLabel.text = timeSince;
		_dateLabel.numberOfLines = 0;
		[_contentHolderView addSubview:_dateLabel];
		
		CGSize tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(300.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_tweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 85.0, 300.0, tweetSize.height)];
		_tweetLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_tweetLabel.textColor = [UIColor whiteColor];
		_tweetLabel.backgroundColor = [UIColor clearColor];
		_tweetLabel.text = _vo.tweetMessage;
		_tweetLabel.numberOfLines = 0;
		[_contentHolderView addSubview:_tweetLabel];
	}
	
	return (self);
}

-(void)dealloc {
	[_contentHolderView release];
	[_avatarImgView release];
	[_tweetLabel release];
	[_twitterName release];
	
	[super dealloc];
}


-(void)_goShare {
	
}

@end
