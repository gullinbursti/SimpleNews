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

#import "EGOImageView.h"

@implementation SNArticleItemView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		int offset = 0;
		CGSize size;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		EGOImageView *thumbImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(25.0, offset, 24.0, 24.0)];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		thumbImgView.layer.cornerRadius = 4.0;
		thumbImgView.clipsToBounds = YES;
		[self addSubview:thumbImgView];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = thumbImgView.frame;
		[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		offset += 4;
		
		NSString *timeSince = @"";
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			timeSince = [NSString stringWithFormat:@"%dd from ", days];
			
		} else {
			if (hours > 0)
				timeSince = [NSString stringWithFormat:@"%dh from ", hours];
			
			else
				timeSince = [NSString stringWithFormat:@"%dm from ", mins];
		}
		
		size = [timeSince sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, offset, size.width, 16.0)];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
		dateLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		CGSize size2 = [[NSString stringWithFormat:@"@%@ ", _vo.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *twitterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateLabel.frame.origin.x + size.width, offset, size2.width, 16.0)];
		twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		twitterNameLabel.textColor = [SNAppDelegate snLinkColor];
		twitterNameLabel.backgroundColor = [UIColor clearColor];
		twitterNameLabel.text = [NSString stringWithFormat:@"@%@", _vo.twitterHandle];
		[self addSubview:twitterNameLabel];
		
		UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		handleButton.frame = twitterNameLabel.frame;
		[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:handleButton];
		
		
		if (_vo.source_id == 0) {
			UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(twitterNameLabel.frame.origin.x + size2.width, offset, 100.0, 16.0)];
			messageLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
			messageLabel.textColor = [UIColor colorWithWhite:0.525 alpha:1.0];
			messageLabel.backgroundColor = [UIColor clearColor];
			messageLabel.text = _vo.title;
			[self addSubview:messageLabel];	
			
		} else {
			size = [@"via " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(twitterNameLabel.frame.origin.x + size2.width, offset, size.width, 16.0)];
			viaLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:12];
			viaLabel.textColor = [UIColor colorWithWhite:0.525 alpha:1.0];
			viaLabel.backgroundColor = [UIColor clearColor];
			viaLabel.text = @"via ";
			[self addSubview:viaLabel];	
			
			size2 = [_vo.articleSource sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(viaLabel.frame.origin.x + size.width, offset, size2.width, 16.0)];
			sourceLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
			sourceLabel.textColor = [SNAppDelegate snLinkColor];
			sourceLabel.backgroundColor = [UIColor clearColor];
			sourceLabel.text = _vo.articleSource;
			[self addSubview:sourceLabel];	
		}
		
		offset += 55;
		
		if (_vo.source_id > 0) {
			size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, offset, 270.0, size.height)];
			titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:16];
			titleLabel.textColor = [UIColor colorWithWhite:0.412 alpha:1.0];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.text = _vo.title;
			titleLabel.numberOfLines = 0;
			[self addSubview:titleLabel];
			
			UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
			detailsButton.frame = titleLabel.frame;
			[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:detailsButton];
			offset += size.height + 35;
			
			UIView *btnBGView = [[UIView alloc] initWithFrame:CGRectMake(68.0, offset, 184.0, 35.0)];
			[btnBGView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.60]];
			btnBGView.layer.cornerRadius = 17.0;
			[self addSubview:btnBGView];
			offset += 72;
			
			
			UIButton *readArticleButton = [UIButton buttonWithType:UIButtonTypeCustom];
			readArticleButton.frame = CGRectMake(5.0, -0.0, 94.0, 34.0);
			[readArticleButton setBackgroundImage:[UIImage imageNamed:@"readArticleButton_nonActive.png"] forState:UIControlStateNormal];
			[readArticleButton setBackgroundImage:[UIImage imageNamed:@"readArticleButton_Active.png"] forState:UIControlStateHighlighted];
			[readArticleButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
			//			[readArticleButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
			//			readArticleButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
			//			readArticleButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
			//			[readArticleButton setTitle:@"Read More" forState:UIControlStateNormal];
			[btnBGView addSubview:readArticleButton];
			
			_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_likeButton.frame = CGRectMake(115.0, -5.0, 65.0, 44.0);
			[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
			[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
			[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
			_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
			_likeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
			[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
			[btnBGView addSubview:_likeButton];
			
			if (_vo.hasLiked)
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_selected.png"] forState:UIControlStateNormal];
			
			else
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		}
		
		if (_vo.type_id > 1) {
			_articleImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(25.0, offset, 270.0, 270.0 * _vo.imgRatio)];
			_articleImgView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
			_articleImgView.userInteractionEnabled = YES;
			[self addSubview:_articleImgView];
			
			UITapGestureRecognizer *dblTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photoZoomIn:)];
			dblTapRecognizer.numberOfTapsRequired = 2;
			[_articleImgView addGestureRecognizer:dblTapRecognizer];
			
			offset += (270.0 * _vo.imgRatio);
			offset += 20;
		}
		
		//CGSize imgSize = NSLog(@"IMAGE SIZE:(%d, %d)", (int)[UIImage imageNamed:@"overlay.png"].size.width, (int)[UIImage imageNamed:@"overlay.png"].size.height);
		
		if (_vo.type_id > 4) {
			_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(25.0, offset, 270.0, 202.0) articleVO:_vo];
			[self addSubview:_videoPlayerView];
			
			_videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_videoButton.frame = CGRectMake(60.0, offset, 242.0, 160.0);
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_videoButton];
			offset += 202.0;
			offset += 20;
		}
		
		int imgOffset = 25;
		
		//if (_vo.source_id > 0) {
			for (NSDictionary *dict in _vo.seenBy) {
				EGOImageView *readImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(imgOffset, offset, 24.0, 24.0)];
				readImgView.layer.cornerRadius = 4.0;
				readImgView.clipsToBounds = YES;
				readImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=reasonably_small", [dict objectForKey:@"handle"]]];
				[self addSubview:readImgView];
				
				UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				avatarButton.frame = readImgView.frame;
				[avatarButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:avatarButton];
				
				imgOffset += 34;
			}
			
			
			UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
			commentButton.frame = CGRectMake(imgOffset - 10.0, offset - 10.0, 44.0, 44.0);
			[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
			[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
			[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:commentButton];
			
			offset += 46;
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
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	NSLog(@"USER_ID:[%d] LIST_ID:[%d] ARTICLE_ID:[%d]", [[[SNAppDelegate profileForUser] objectForKey:@"id"] intValue], _vo.list_id, _vo.article_id);	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_DETAILS" object:_vo];
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
	[_videoButton removeTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
	[_videoButton removeFromSuperview];
	[_videoPlayerView startPlayback];
}

-(void)_photoZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"photo", @"type", 
								 _vo, @"VO", 
								 [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
								 [NSValue valueWithCGRect:_articleImgView.frame], @"frame", nil];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FULLSCREEN_MEDIA" object:dict];
}


-(void)_goAffiliate {
	NSLog(@"AFFILIATE");
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_vo.affiliateURL]];
}

-(void)_goLike {
	ASIFormDataRequest *readRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActiveSelected.png"] forState:UIControlStateNormal];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActiveSelected.png"] forState:UIControlStateHighlighted];
	[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[likeRequest startAsynchronous];
	
	_vo.totalLikes++;
	_likesLabel.text = [NSString stringWithFormat:@"%d", _vo.totalLikes];
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SHEET" object:_vo];
}


-(void)_goComment {
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
	NSLog(@"SNArticleItem_iPhone [_asiFormRequest error]=\n%@\n\n", [request error]);
}
@end
