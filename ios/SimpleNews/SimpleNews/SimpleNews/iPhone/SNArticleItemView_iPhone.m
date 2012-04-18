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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
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
		
		UIButton *detailsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		detailsButton.frame = CGRectMake(66.0, offset, 242.0, size.height);
		[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:detailsButton];
		
		offset += size.height + 16;
		int offset2 = offset - size.height - 20;
		
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
			
			_videoButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_videoButton.frame = CGRectMake(60.0, offset, 242.0, 160.0);
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_videoButton];
			
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
		commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:9.0];
		commentButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		commentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -10.0);
		[commentButton setTitle:@"Comments" forState:UIControlStateNormal];
		[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:commentButton];
		
		UIButton *shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		shareButton.frame = CGRectMake(262.0, offset, 49.0, 34.0);
		[shareButton setBackgroundImage:[UIImage imageNamed:@"moreOptionsButton_nonActive.png"] forState:UIControlStateNormal];
		[shareButton setBackgroundImage:[UIImage imageNamed:@"moreOptionsButton_Active.png"] forState:UIControlStateHighlighted];
		[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:shareButton];
		
		offset += 50;
		
		UIView *ltLineView = [[[UIView alloc] initWithFrame:CGRectMake(56, offset2, 1.0, offset - offset2)] autorelease];
		[ltLineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:ltLineView];	
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, offset, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:lineView];
	}
	
	return (self);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEO_ENDED" object:nil];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	if (CGRectContainsPoint(_videoPlayerView.frame, touchPoint))
		[_videoPlayerView toggleControls];//NSLog(@"TOUCHED:(%f, %f)", touchPoint.x, touchPoint.y);
}


#pragma mark - Navigation
-(void)_goDetails {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_DETAILS" object:_vo];
}

-(void)_goLike {
	
}

-(void)_goComment {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_COMMENTS" object:_vo];
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SHEET" object:_vo];
}

-(void)_goVideo {
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
	[_videoButton removeTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
	[_videoButton removeFromSuperview];
	[_videoPlayerView startPlayback];
}



#pragma mark - Notification handlers
-(void)_videoEnded:(NSNotification *)notification {
	[self addSubview:_videoButton];
	[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
}

@end
