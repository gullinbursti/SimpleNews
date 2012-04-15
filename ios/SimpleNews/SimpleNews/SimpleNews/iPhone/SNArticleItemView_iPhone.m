//
//  SNArticleItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleItemView_iPhone.h"
#import "SNAppDelegate.h"

#import "EGOImageView.h"

@implementation SNArticleItemView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		int offset = 46;
		CGSize size;
		
		EGOImageView *thumbImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 35.0, 35.0)] autorelease];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[self addSubview:thumbImgView];
		
		UILabel *twitterName = [[[UILabel alloc] initWithFrame:CGRectMake(56.0, 21.0, 256.0, 20.0)] autorelease];
		twitterName.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		twitterName.textColor = [UIColor blackColor];
		twitterName.backgroundColor = [UIColor clearColor];
		twitterName.text = _vo.twitterName;
		[self addSubview:twitterName];
		
		NSString *timeSince = @"";
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			timeSince = [NSString stringWithFormat:@"%dd", days];
			
		} else {
			if (hours > 0)
				timeSince = [NSString stringWithFormat:@"%dh", hours];
			
			else
				timeSince = [NSString stringWithFormat:@"%dm", mins];
		}
		
		UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(208.0, 21.0, 100.0, 16.0)] autorelease];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		dateLabel.textColor = [UIColor colorWithWhite:0.800 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textAlignment = UITextAlignmentRight;
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		size = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(252.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];		
		UILabel *tweetLabel = [[[UILabel alloc] initWithFrame:CGRectMake(56.0, 46.0, 252.0, size.height)] autorelease];
		tweetLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		tweetLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		tweetLabel.backgroundColor = [UIColor clearColor];
		tweetLabel.text = _vo.tweetMessage;
		tweetLabel.numberOfLines = 0;
		[self addSubview:tweetLabel];
		offset += size.height + 25;
		
		size = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(242.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(66.0, offset, 242.0, size.height)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:16];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = _vo.title;
		titleLabel.numberOfLines = 0;
		[self addSubview:titleLabel];
		offset += size.height + 16;
		
		size = [_vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(242.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		UILabel *sourceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(66.0, offset, 242.0, size.height)] autorelease];
		sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		sourceLabel.textColor = [UIColor blackColor];
		sourceLabel.backgroundColor = [UIColor clearColor];
		sourceLabel.text = _vo.articleSource;
		[self addSubview:sourceLabel];
		offset += size.height + 14;
		
		if (_vo.type_id > 4) {
			_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(66.0, offset, 242.0, 180.0) articleVO:_vo];
			[self addSubview:_videoPlayerView];
			
			UIButton *videoButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			videoButton.frame = CGRectMake(60.0, offset, 242.0, 160.0);
			//[videoButton setBackgroundColor:[UIColor greenColor]];
			//videoButton.alpha = 0.33;
			[videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:videoButton];
			
			offset += 180.0 + 16;
		}
		
		UIButton *likeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		likeButton.frame = CGRectMake(60.0, offset, 44.0, 34.0);
		[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:likeButton];
		
		UIButton *commentButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		commentButton.frame = CGRectMake(110.0, offset, 84.0, 34.0);
		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive.png"] forState:UIControlStateNormal];
		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active.png"] forState:UIControlStateHighlighted];
		[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:commentButton];
		
		UIButton *moreButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		moreButton.frame = CGRectMake(262.0, offset, 49.0, 34.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreOptionsButton_nonActive.png"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreOptionsButton_Active.png"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goAddlOptions) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:moreButton];
		
		offset += 50;
		
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, offset, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:lineView];
	}
	
	return (self);
}

-(void)dealloc {
	
}


#pragma mark - Navigation
-(void)_goVideo {
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
	[_videoPlayerView startPlayback];
}


-(void)_goLike {
	
}

-(void)_goComment {
	
}

-(void)_goAddlOptions {
	
}

@end
