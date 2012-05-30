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
		
		int offset = 25;
		CGSize size;
		CGSize size2;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, frame.size.height)];
		[self addSubview:bgView];
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-10.0, 0.0, 320.0, frame.size.height)];
		UIImage *img = [UIImage imageNamed:@"cardBackground.png"];
		bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:50.0];
		[self addSubview:bgImgView];
		
		EGOImageView *thumbImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, offset, 25.0, 25.0)];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[self addSubview:thumbImgView];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = thumbImgView.frame;
		[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		offset += 5;
		
		size = [@"via 	" sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, offset, size.width, size.height)];
		viaLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
		viaLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
		viaLabel.backgroundColor = [UIColor clearColor];
		viaLabel.text = @"via ";
		[self addSubview:viaLabel];
		
		size2 = [[NSString stringWithFormat:@"@%@ ", _vo.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0 + size.width, offset, size2.width, size2.height)];
		handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		handleLabel.textColor = [SNAppDelegate snLinkColor];
		handleLabel.backgroundColor = [UIColor clearColor];
		handleLabel.text = [NSString stringWithFormat:@"@%@ ", _vo.twitterHandle];
		[self addSubview:handleLabel];
		
		size = [@"in " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *inLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x + size2.width, offset, size.width, size.height)];
		inLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
		inLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
		inLabel.backgroundColor = [UIColor clearColor];
		inLabel.text = @"in ";
		[self addSubview:inLabel];
		
		size2 = [[NSString stringWithFormat:@"%@", _vo.topicTitle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(inLabel.frame.origin.x + size.width, offset, size2.width, size2.height)];
		topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		topicLabel.textColor = [SNAppDelegate snLinkColor];
		topicLabel.backgroundColor = [UIColor clearColor];
		topicLabel.text = [NSString stringWithFormat:@"%@", _vo.topicTitle];
		[self addSubview:topicLabel];
		
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
		
		size = [timeSince sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(285.0 - size.width, offset, size.width, size.height)];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		dateLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textAlignment = UITextAlignmentRight;
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		size2 = [_vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateLabel.frame.origin.x + size.width, offset, size2.width, 12.0)];
		sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
		sourceLabel.textColor = [SNAppDelegate snLinkColor];
		sourceLabel.backgroundColor = [UIColor clearColor];
		sourceLabel.text = _vo.articleSource;
		[self addSubview:sourceLabel];
		
		UIButton *sourceLblButton = [UIButton buttonWithType:UIButtonTypeCustom];
		sourceLblButton.frame = sourceLabel.frame;
		[sourceLblButton addTarget:self action:@selector(_goSourcePage) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:sourceLblButton];
		
		offset += 41;
		
		if (_vo.type_id >= 2) {
			size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, offset, 260.0, size.height)];
			titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
			titleLabel.textColor = [SNAppDelegate snLinkColor];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.text = _vo.title;
			titleLabel.numberOfLines = 0;
			[self addSubview:titleLabel];
			offset += size.height + 30.0;
		}
		
		if (_vo.type_id == 2 || _vo.type_id == 3) {
			_articleImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, offset, 260.0, 260.0 * _vo.imgRatio)];
			[_articleImgView setDelegate:self];
			[_articleImgView setBackgroundColor:[UIColor lightGrayColor]];
			_articleImgView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
			_articleImgView.userInteractionEnabled = YES;
			[self addSubview:_articleImgView];
			
			UITapGestureRecognizer *dblTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photoZoomIn:)];
			dblTapRecognizer.numberOfTapsRequired = 2;
			[_articleImgView addGestureRecognizer:dblTapRecognizer];
			
			offset += (260.0 * _vo.imgRatio);
			offset += 20;
		}
		
		if (_vo.type_id > 3) {
			_videoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, offset, 260.0, 195.0)];
			_videoImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _vo.video_url]];
			[self addSubview:_videoImgView];
			
			_videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_videoButton.frame = _videoImgView.frame;
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_videoButton];
			offset += 195;
			offset += 20;
		}
		
		UIView *btnBGView = [[UIView alloc] initWithFrame:CGRectMake(10.0, offset, 174.0, 44.0)];
		btnBGView.userInteractionEnabled = YES;
		[self addSubview:btnBGView];
		
		UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		commentButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive.png"] forState:UIControlStateNormal];
		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active.png"] forState:UIControlStateHighlighted];
		[commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
		[commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
		commentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
		[commentButton setTitle:[NSString stringWithFormat:@"%d", 0] forState:UIControlStateNormal];
		[btnBGView addSubview:commentButton];
		
		_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButton.frame = CGRectMake(70.0, 0.0, 64.0, 44.0);
		[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
		_likeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, -6.0);
		[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
		[btnBGView addSubview:_likeButton];
		
		if (_vo.hasLiked) {
			[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
			[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
			
		} else {
			[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
			[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		}
		
		UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
		sourceButton.frame = CGRectMake(248.0, offset, 44.0, 44.0);
		[sourceButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
		[sourceButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
		[sourceButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:sourceButton];
		
//		int imgOffset = 25;
//		for (NSDictionary *dict in _vo.seenBy) {
//			EGOImageView *readImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(imgOffset, offset, 24.0, 24.0)];
//			readImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=reasonably_small", [dict objectForKey:@"handle"]]];
//			[self addSubview:readImgView];
//			
//			UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			avatarButton.frame = readImgView.frame;
//			[avatarButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:avatarButton];
//			
//			imgOffset += 34;
//		}
		
		
//		UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		commentButton.frame = CGRectMake(imgOffset - 5.0, offset - 5.0, 34.0, 34.0);
//		[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
//		[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
//		[commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:commentButton];
		
		
	}
	
	return (self);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEO_ENDED" object:nil];
}


#pragma mark - Navigation
-(void)_goDetails {
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
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"photo", @"type", 
								 _vo, @"VO", 
								 [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
								 [NSValue valueWithCGRect:CGRectMake(_articleImgView.frame.origin.x + self.frame.origin.x, _articleImgView.frame.origin.y, _articleImgView.frame.size.width, _articleImgView.frame.size.height)], @"frame", nil];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}


-(void)_goSourcePage {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SOURCE_PAGE" object:_vo];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHEET" object:_vo];
}


-(void)_goComments {
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_COMMENTS" object:_vo];
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
//	imageView.image = [SNAppDelegate imageWithFilters:imageView.image filter:[NSArray arrayWithObjects:
//																									  [NSDictionary dictionaryWithObjectsAndKeys:
//																										@"sepia", @"type", nil, nil], 
//																									  nil]];
	
	imageView.image = [SNAppDelegate imageWithFilters:imageView.image filter:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"saturation", @"type", [NSNumber numberWithFloat:1.0], @"amount", nil], nil]];
}

@end
