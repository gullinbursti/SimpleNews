//
//  SNDiscoveryArticleCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.05.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNDiscoveryArticleCardView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNUnderlinedLabel.h"

#import "ImageFilter.h"

@implementation SNDiscoveryArticleCardView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		//int offset = 20;
		[self setBackgroundColor:[UIColor whiteColor]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		if (_vo.type_id > 1) {
			_articleImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20.0, 210 - ((280.0 * _vo.imgRatio) * 0.5), 280.0, 280.0 * _vo.imgRatio)];
			[_articleImgView setDelegate:self];
			_articleImgView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
			_articleImgView.userInteractionEnabled = YES;
			[self addSubview:_articleImgView];
			
			UITapGestureRecognizer *dblTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photoZoomIn:)];
			dblTapRecognizer.numberOfTapsRequired = 2;
			[_articleImgView addGestureRecognizer:dblTapRecognizer];
		}
		
		CGSize size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(227.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 210 - (size.height * 0.5), 270.0, size.height)];
		titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.text = [[NSString stringWithFormat:@"“%@”", _vo.title] uppercaseString];
		titleLabel.numberOfLines = 0;
		[self addSubview:titleLabel];
		
		UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		detailsButton.frame = titleLabel.frame;
		[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:detailsButton];
		
		
		UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		commentButton.frame = CGRectMake(84.0, (_articleImgView.frame.origin.y + _articleImgView.frame.size.height) - 60.0, 94.0, 44.0);
		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive.png"] forState:UIControlStateNormal];
		[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active.png"] forState:UIControlStateHighlighted];
		[commentButton addTarget:self action:@selector(_goComment) forControlEvents:UIControlEventTouchUpInside];
		[commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
		commentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
		[commentButton setTitle:@"Comment" forState:UIControlStateNormal];
		[self addSubview:commentButton];
		
		_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButton.frame = CGRectMake(178.0, (_articleImgView.frame.origin.y + _articleImgView.frame.size.height) - 60.0, 74.0, 44.0);
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
		_likeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
		[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
		[self addSubview:_likeButton];
		
		if (_vo.hasLiked)
			[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
		
		else
			[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		
		
		if (_vo.type_id > 4) {
			//_videoPlayerView = [[SNArticleVideoPlayerView_iPhone alloc] initWithFrame:CGRectMake(25.0, _articleImgView.frame.origin.y + _articleImgView.frame.size.height + 32.0, 270.0, 202.0) articleVO:_vo];
			//[self addSubview:_videoPlayerView];
			
			_videoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(25.0, _articleImgView.frame.origin.y + _articleImgView.frame.size.height + 32.0, 270.0, 202.0)];
			_videoImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _vo.video_url]];
			[self addSubview:_videoImgView];
			
			_videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_videoButton.frame = _videoPlayerView.frame;
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_videoButton];
		}
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
	//[_videoPlayerView startPlayback];
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
		
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Selected.png"] forState:UIControlStateHighlighted];
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

#pragma mark - Image View delegates
-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	NSLog(@"LOADED [%@]", imageView.imageURL);
	UIImage *img = imageView.image;
	imageView.image = [img saturate:(1 + 1 - 0.5)];
}

@end
