//
//  SNArticleItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNArticleItemView_iPhone.h"
#import "SNAppDelegate.h"
#import "SNUnderlinedLabel.h"
#import "SNWebPageViewController_iPhone.h"
#import "ImageFilter.h"
#import "SNArticleVideoPlayerView_iPhone.h"

@implementation SNArticleItemView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		int offset = 20;
		CGSize size;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		EGOImageView *thumbImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, offset, 25.0, 25.0)];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[self addSubview:thumbImgView];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = thumbImgView.frame;
		[avatarButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		offset += 7;
		
		NSString *timeSince = @"";
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			timeSince = [NSString stringWithFormat:@"%dd via ", days];
			
		} else {
			if (hours > 0)
				timeSince = [NSString stringWithFormat:@"%dh via ", hours];
			
			else
				timeSince = [NSString stringWithFormat:@"%dm via ", mins];
		}
		
		size = [timeSince sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, offset, size.width, 12.0)];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10];
		dateLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		CGSize size2 = [_vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateLabel.frame.origin.x + size.width, offset, size2.width, 12.0)];
		sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
		sourceLabel.textColor = [SNAppDelegate snLinkColor];
		sourceLabel.backgroundColor = [UIColor clearColor];
		sourceLabel.text = _vo.articleSource;
		[self addSubview:sourceLabel];
		
		UIButton *sourceLblButton = [UIButton buttonWithType:UIButtonTypeCustom];
		sourceLblButton.frame = sourceLabel.frame;
		[sourceLblButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:sourceLblButton];
		
		UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
		sourceButton.frame = CGRectMake(273.0, 16.0, 34.0, 34.0);
		[sourceButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
		[sourceButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
		[sourceButton addTarget:self action:@selector(_goSourcePage) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:sourceButton];
		
		offset += 41;
		
		if (_vo.source_id > 0) {
			size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:16] constrainedToSize:CGSizeMake(270.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, offset, 270.0, size.height)];
			titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:16];
			titleLabel.textColor = [UIColor blackColor];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.text = _vo.title;
			titleLabel.numberOfLines = 0;
			[self addSubview:titleLabel];
			
			UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
			detailsButton.frame = titleLabel.frame;
			[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:detailsButton];
			offset += size.height + 15;
			
			UIImageView *btnBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(73.0, offset, 174.0, 44.0)];
			btnBGImgView.image = [UIImage imageNamed:@"commentLikeButton_BG.png"];
			btnBGImgView.userInteractionEnabled = YES;
			[self addSubview:btnBGImgView];
			offset += 70;
			
			
			UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
			commentButton.frame = CGRectMake(6.0, 0.0, 94.0, 44.0);
			[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive.png"] forState:UIControlStateNormal];
			[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active.png"] forState:UIControlStateHighlighted];
			[commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
			[commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
			commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
			commentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -10.0);
			[commentButton setTitle:@"Comment" forState:UIControlStateNormal];
			[btnBGImgView addSubview:commentButton];
			
			_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_likeButton.frame = CGRectMake(98.0, 0.0, 74.0, 44.0);
			[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
			_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
			_likeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
			[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
			[btnBGImgView addSubview:_likeButton];
			
			if (_vo.hasLiked) {
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateHighlighted];
				[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
				
			} else {
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
				[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
			}
		}
		
		if (_vo.type_id > 1) {
			_articleImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, offset, 280.0, 280.0 * _vo.imgRatio)];
			[_articleImgView setDelegate:self];
			[_articleImgView setBackgroundColor:[UIColor lightGrayColor]];
			_articleImgView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
			_articleImgView.userInteractionEnabled = YES;
			[self addSubview:_articleImgView];
			
			UITapGestureRecognizer *dblTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photoZoomIn:)];
			dblTapRecognizer.numberOfTapsRequired = 2;
			[_articleImgView addGestureRecognizer:dblTapRecognizer];
			
			offset += (280.0 * _vo.imgRatio);
			offset += 20;
		}
		
		if (_vo.type_id > 4) {
			_videoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, offset, 280.0, 210.0)];
			_videoImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _vo.video_url]];
			[self addSubview:_videoImgView];
			
			_videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_videoButton.frame = _videoImgView.frame;
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_videoButton];
			offset += 210.0;
			offset += 20;
		}
		
		int imgOffset = 25;
		for (NSDictionary *dict in _vo.seenBy) {
			EGOImageView *readImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(imgOffset, offset, 24.0, 24.0)];
			readImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=reasonably_small", [dict objectForKey:@"handle"]]];
			[self addSubview:readImgView];
			
			UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
			avatarButton.frame = readImgView.frame;
			[avatarButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:avatarButton];
			
			imgOffset += 34;
		}
		
		
		UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		commentButton.frame = CGRectMake(imgOffset - 5.0, offset - 5.0, 34.0, 34.0);
		[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
		[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
		[commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:commentButton];
		
		offset += 46;
	}
	
	return (self);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEO_ENDED" object:nil];
}


#pragma mark - Navigation
-(void)_goDetails {
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	NSLog(@"USER_ID:[%d] LIST_ID:[%d] ARTICLE_ID:[%d]", [[[SNAppDelegate profileForUser] objectForKey:@"id"] intValue], _vo.list_id, _vo.article_id);	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_DETAILS" object:_vo];
}

-(void)_goVideo {
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_VIDEO" object:nil];
	//[_videoButton removeTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
	//[_videoButton removeFromSuperview];
	//[_videoPlayerView startPlayback];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"video", @"type", 
								 _vo, @"VO", 
								 [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
								 [NSValue valueWithCGRect:_videoImgView.frame], @"frame", nil];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FULLSCREEN_MEDIA" object:dict];
	
	
}

-(void)_photoZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"photo", @"type", 
								 _vo, @"VO", 
								 [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
								 [NSValue valueWithCGRect:_articleImgView.frame], @"frame", nil];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FULLSCREEN_MEDIA" object:dict];
}


-(void)_goSourcePage {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								 _vo.article_url, @"url", 
								 _vo.title, @"title", nil];
								 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SOURCE_PAGE" object:dict];
}

-(void)_goLike {
	
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	
	} else {
		ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		[readRequest setDelegate:self];
		[readRequest startAsynchronous];
		
		[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[_likeButton setTitle:[NSString stringWithFormat:@"%d", ++_vo.totalLikes] forState:UIControlStateNormal];
		
		ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
		[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
		[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		[likeRequest startAsynchronous];
		
		_vo.hasLiked = YES;
	}
}

-(void)_goDislike {
	
	[_likeButton removeTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
	[_likeButton setTitle:[NSString stringWithFormat:@"%d", --_vo.totalLikes] forState:UIControlStateNormal];
	
	ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
	[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[likeRequest startAsynchronous];
	
	_vo.hasLiked = NO;
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SHEET" object:_vo];
}


-(void)_goComments {
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_COMMENTS" object:_vo];
}


-(void)_goTwitterProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:_vo.twitterHandle];
}


#pragma mark - Notification handlers
-(void)_videoEnded:(NSNotification *)notification {
	[self addSubview:_videoButton];
	[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleItem_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

#pragma mark - Image View delegates
-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	imageView.image = [SNAppDelegate imageWithFilters:imageView.image filter:[NSArray arrayWithObjects:
																									  [NSDictionary dictionaryWithObjectsAndKeys:
																										@"sepia", @"type", nil, nil], 
																									  nil]];
}

@end
