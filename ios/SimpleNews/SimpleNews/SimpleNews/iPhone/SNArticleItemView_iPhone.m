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
		
		int offset = 46;
		CGSize size;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		NSString *timeSince = @"";
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (_vo.source_id == 0) {
			UIImageView *linesImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 60.0)] autorelease];
			linesImgView.image = [[UIImage imageNamed:@"nonContentRow.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
			[self addSubview:linesImgView];
		}
		
		if (days > 0) {
			timeSince = [NSString stringWithFormat:@"%dd", days];
			
		} else {
			if (hours > 0)
				timeSince = [NSString stringWithFormat:@"%dh", hours];
			
			else
				timeSince = [NSString stringWithFormat:@"%dm", mins];
		}
		
		size = [timeSince sizeWithFont:[SNAppDelegate snAllerFontRegular] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80.0, 24.0, size.width, 16.0)] autorelease];
		dateLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:12];
		dateLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		CGSize size2 = [[NSString stringWithFormat:@"@%@", _vo.twitterHandle] sizeWithFont:[SNAppDelegate snHelveticaNeueFontBold] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *twitterNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80.0 + size.width, 24.0, size2.width, 16.0)] autorelease];
		twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		twitterNameLabel.textColor = [UIColor colorWithWhite:0.525 alpha:1.0];
		twitterNameLabel.backgroundColor = [UIColor clearColor];
		twitterNameLabel.text = [NSString stringWithFormat:@"@%@", _vo.twitterHandle];
		[self addSubview:twitterNameLabel];
		
		if (_vo.source_id == 0) {
			UILabel *messageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70.0 + size.width + size2.width, 24.0, 100.0, 16.0)] autorelease];
			messageLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:12];
			messageLabel.textColor = [UIColor colorWithWhite:0.525 alpha:1.0];
			messageLabel.backgroundColor = [UIColor clearColor];
			messageLabel.text = _vo.title;
			[self addSubview:messageLabel];	
		}
		
		offset += 20;
		
		UIButton *handleButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		handleButton.frame = twitterNameLabel.frame;
		[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:handleButton];
		
		
		if (_vo.source_id > 0) {
			size = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
			UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80.0, offset, 227.0, size.height)] autorelease];
			titleLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
			titleLabel.textColor = [UIColor blackColor];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.text = _vo.title;
			titleLabel.numberOfLines = 0;
			[self addSubview:titleLabel];
			
			UIButton *detailsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			detailsButton.frame = titleLabel.frame;
			[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:detailsButton];
			offset += size.height + 20;
		}
		
		int offset2 = offset + 25;
		
		if (_vo.type_id > 1) {
			EGOImageView *articleImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(80.0, offset, 227.0, 227.0 * _vo.imgRatio)] autorelease];
			articleImgView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
			[self addSubview:articleImgView];
			
			UIButton *ctaButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			ctaButton.frame = articleImgView.frame;
			ctaButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, (articleImgView.frame.size.width * 0.5) - 11.0, 0.0, -((articleImgView.frame.size.width * 0.5) - 11.0));
			[ctaButton setImage:[UIImage imageNamed:@"ctaButton_nonActive.png"] forState:UIControlStateNormal];
			[ctaButton setImage:[UIImage imageNamed:@"ctaButton_Active.png"] forState:UIControlStateHighlighted];
			[ctaButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:ctaButton];
			
			offset += (227.0 * _vo.imgRatio);
			offset += 20;
		}
		
		//CGSize imgSize = NSLog(@"IMAGE SIZE:(%d, %d)", (int)[UIImage imageNamed:@"overlay.png"].size.width, (int)[UIImage imageNamed:@"overlay.png"].size.height);
				
		if (_vo.type_id > 4) {
			_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(80.0, offset, 227.0, 180.0) articleVO:_vo];
			[self addSubview:_videoPlayerView];
			
			_videoButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_videoButton.frame = CGRectMake(60.0, offset, 242.0, 160.0);
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_videoButton];
			offset += 180.0;
		}
		
		offset += 12;
		
		int imgOffset = 80;
		for (NSDictionary *dict in _vo.seenBy) {
			EGOImageView *readImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(imgOffset, offset, 24.0, 24.0)] autorelease];
			readImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=reasonably_small", [dict objectForKey:@"handle"]]];
			[self addSubview:readImgView];
			
			UIButton *avatarButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			avatarButton.frame = readImgView.frame;
			[avatarButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:avatarButton];
			
			imgOffset += 34;
		}
		
		
		if (_vo.source_id > 0) {
			UIButton *commentButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			commentButton.frame = CGRectMake(imgOffset - 10.0, offset - 10.0, 44.0, 44.0);
			[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
			[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
			[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:commentButton];
			
			offset += 46;
			
			UIImageView *linesImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, offset)] autorelease];
			linesImgView.image = [[UIImage imageNamed:@"contentRow.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
			[self addSubview:linesImgView];
			
			_likeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_likeButton.frame = CGRectMake(15.0, offset2, 34.0, 34.0);
			
			if (_vo.hasLiked)
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActiveSelected.png"] forState:UIControlStateNormal];
			
			else
				[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
			
			[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
			[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_likeButton];
			
			UIButton *favButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			favButton.frame = CGRectMake(15.0, offset2 + 59.0, 34.0, 34.0);
			[favButton setBackgroundImage:[UIImage imageNamed:@"favButton_nonActive.png"] forState:UIControlStateNormal];
			[favButton setBackgroundImage:[UIImage imageNamed:@"favButton_Active.png"] forState:UIControlStateHighlighted];
			[favButton addTarget:self action:@selector(_goReadLater) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:favButton];
			
			UIButton *shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			shareButton.frame = CGRectMake(15.0, offset2 + 118.0, 34.0, 34.0);
			[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive.png"] forState:UIControlStateNormal];
			[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active.png"] forState:UIControlStateHighlighted];
			[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:shareButton];
		
		} else {
			UIButton *commentButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			commentButton.frame = CGRectMake(270.0, 10.0, 44.0, 44.0);
			[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
			[commentButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
			[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:commentButton];
		}
		
		EGOImageView *thumbImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 35.0, 35.0)] autorelease];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		thumbImgView.layer.cornerRadius = 8.0;
		thumbImgView.clipsToBounds = YES;
		[self addSubview:thumbImgView];
		
		UIButton *avatarButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		avatarButton.frame = thumbImgView.frame;
		[avatarButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
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
	ASIFormDataRequest *readRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
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
	ASIFormDataRequest *readRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
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

-(void)_goLike {
	NSLog(@"GO LIKE");
	ASIFormDataRequest *readRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActiveSelected.png"] forState:UIControlStateNormal];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActiveSelected.png"] forState:UIControlStateHighlighted];
	[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	ASIFormDataRequest *likeRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[likeRequest startAsynchronous];
}

-(void)_goReadLater {
	ASIFormDataRequest *readRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[readRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readRequest setDelegate:self];
	[readRequest startAsynchronous];
	
	ASIFormDataRequest *readLaterRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
	[readLaterRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[readLaterRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[readLaterRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.list_id] forKey:@"listID"];
	[readLaterRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	[readLaterRequest startAsynchronous];
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SHEET" object:_vo];
}


-(void)_goComment {
	ASIFormDataRequest *readRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
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
