//
//  SNDiscoveryItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNDiscoveryItemView_iPhone.h"

#import "SNAppDelegate.h"

@interface SNDiscoveryItemView_iPhone() <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *imageResource;
@end

@implementation SNDiscoveryItemView_iPhone

@synthesize imageResource = _imageResource;

- (id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, frame.size.height)];
		UIImage *img = [UIImage imageNamed:@"cardBackground.png"];
		bgImgView.image = [img stretchableImageWithLeftCapWidth:10.0 topCapHeight:20.0];
		[self addSubview:bgImgView];
		
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 50.0, 320.0, 18.0)];
		titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		titleLabel.textColor = [SNAppDelegate snLinkColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.text = _vo.title;
		[self addSubview:titleLabel];
		
		_articleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 100.0, 300.0, 300.0 * _vo.imgRatio)];
		[_articleImgView setBackgroundColor:[UIColor whiteColor]];
		_articleImgView.userInteractionEnabled = YES;
		[self addSubview:_articleImgView];
		
		if (_imageResource == nil) {			
			self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:_vo.imageURL forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration from now
		}
		
		if (_vo.type_id > 3) {
			
			_videoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(10.0, 100.0, 305.0, 229.0)];
			_videoImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _vo.video_url]];
			[self addSubview:_videoImgView];
			
			_videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_videoButton.frame = _videoImgView.frame;
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_videoButton];
			
			UIImageView *playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(120.0, 82.0, 64.0, 64.0)];
			playImgView.image = [UIImage imageNamed:@"playButton_nonActive.png"];
			[_videoImgView addSubview:playImgView];

		}
		
		if ([_vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
			
		}
		
		
		_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButton.frame = CGRectMake(6.0, 300.0, 64.0, 44.0);
		[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"genericButtonB_nonActive.png"] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"genericButtonB_Active.png"] forState:UIControlStateHighlighted];
		[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
		[_likeButton setImage:[UIImage imageNamed:@"heartIcon.png"] forState:UIControlStateNormal];
		[_likeButton setImage:[UIImage imageNamed:@"heartIcon_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:_likeButton];
		
		if (_vo.hasLiked)
			[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		
		else
			[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		
		if (_vo.totalLikes > 0) {
			_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
			[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
		}
		
		_commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_commentButton.frame = CGRectMake(70.0, 300.0, 64.0, 44.0);
		[_commentButton setBackgroundImage:[UIImage imageNamed:@"genericButtonB_nonActive.png"] forState:UIControlStateNormal];
		[_commentButton setBackgroundImage:[UIImage imageNamed:@"genericButtonB_Active.png"] forState:UIControlStateHighlighted];
		[_commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
		[_commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
		[_commentButton setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
		[_commentButton setImage:[UIImage imageNamed:@"commentIcon_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:_commentButton];
		
		if ([_vo.comments count] > 0) {
			_commentButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
			[_commentButton setTitle:[NSString stringWithFormat:@"%d", [_vo.comments count]] forState:UIControlStateNormal];
		}
		
		
		UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
		sourceButton.frame = CGRectMake(231.0, 300.0, 64.0, 44.0);
		[sourceButton setBackgroundImage:[[UIImage imageNamed:@"genericButtonB_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[sourceButton setBackgroundImage:[[UIImage imageNamed:@"genericButtonB_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[sourceButton setImage:[UIImage imageNamed:@"moreIcon_nonActive.png"] forState:UIControlStateNormal];
		[sourceButton setImage:[UIImage imageNamed:@"moreIcon_Active.png"] forState:UIControlStateHighlighted];
		[sourceButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:sourceButton];
		
	}
	
	return (self);
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHEET" object:_vo];
}


-(void)setImageResource:(MBLAsyncResource *)imageResource {
	if (_imageResource != nil) {
		[_imageResource unsubscribe:self];
		_imageResource = nil;
	}
	
	_imageResource = imageResource;
	
	if (_imageResource != nil)
		[_imageResource subscribe:self];
}


#pragma mark - Navigation
-(void)_goLike {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
	} else {		
		[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		
		/*
		_likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		_likeRequest.delegate = self;
		[_likeRequest startAsynchronous];
		 */
		
		_vo.hasLiked = YES;
	}
}

-(void)_goDislike {
	
	[_likeButton removeTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	/*
	_likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
	[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
	[_likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	_likeRequest.delegate = self;
	[_likeRequest startAsynchronous];
	*/
	_vo.hasLiked = NO;
}

- (void)_goComments {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
	} else {		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_COMMENTS" object:_vo];
	}
}


#pragma mark - Async Resource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	_articleImgView.image = [UIImage imageWithData:data];
	//_articleImgView.image = [SNAppDelegate imageWithFilters:[UIImage imageWithData:data] filter:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"saturation", @"type", [NSNumber numberWithFloat:1.0], @"amount", nil], nil]];
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
}


@end
