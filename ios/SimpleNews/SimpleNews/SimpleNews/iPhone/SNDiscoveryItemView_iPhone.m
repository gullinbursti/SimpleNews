//
//  SNDiscoveryItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 06.12.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNDiscoveryItemView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNImageVO.h"
#import "SNTwitterUserVO.h"
#import "SNTwitterAvatarView.h"

@interface SNDiscoveryItemView_iPhone() <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *imageResource;
@end

@implementation SNDiscoveryItemView_iPhone

@synthesize imageResource = _imageResource;

- (id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		NSString *cardBG;
		
		if (_vo.totalLikes > 0)
			cardBG = @"defaultCardDiscover_Likes.png";
		
		else
			cardBG = @"defaultCardDiscover_noLikes.png";
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 8.0, 308.0, 408.0)];
		UIImage *img = [UIImage imageNamed:cardBG];
		bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:20.0];
		bgImgView.userInteractionEnabled = YES;
		[self addSubview:bgImgView];
		
		_articleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0, 8.0, 290.0, 290.0 * ((SNImageVO *)[_vo.images objectAtIndex:0]).ratio)];
		[_articleImgView setBackgroundColor:[UIColor whiteColor]];
		_articleImgView.userInteractionEnabled = YES;
		[bgImgView addSubview:_articleImgView];
		
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photoZoomIn:)];
		tapRecognizer.numberOfTapsRequired = 1;
		[_articleImgView addGestureRecognizer:tapRecognizer];
		
		if (_imageResource == nil) {			
			self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:((SNImageVO *)[_vo.images objectAtIndex:0]).url forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration from now
		}
		
		if (_vo.type_id > 3) {
			UIView *matteView = [[UIView alloc] initWithFrame:CGRectMake(9.0, 8.0, 290.0, 344.0)];
			[matteView setBackgroundColor:[UIColor blackColor]];
			[bgImgView addSubview:matteView];
			
			_videoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(9.0, 99.0, 290.0, 217.0)];
			_videoImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _vo.video_url]];
			[bgImgView addSubview:_videoImgView];
			
			_videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_videoButton.frame = _videoImgView.frame;
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[bgImgView addSubview:_videoButton];
			
			UIImageView *playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(120.0, 84.0, 64.0, 64.0)];
			playImgView.image = [UIImage imageNamed:@"playButton_nonActive.png"];
			[_videoImgView addSubview:playImgView];
			
		}
		
		UIView *titleBGView = [[UIView alloc] initWithFrame:CGRectMake(9.0, 8.0, 290.0, 52.0)];
		[titleBGView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		titleBGView.userInteractionEnabled = YES;
		[bgImgView addSubview:titleBGView];
		
		CGSize size;
		CGSize size2;
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, 24.0, 250.0, 18.0)];
		titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = _vo.title;
		[self addSubview:titleLabel];
		
		size = [@"via 	" sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, 41.0, size.width, size.height)];
		viaLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12];
		viaLabel.textColor = [UIColor whiteColor];
		viaLabel.backgroundColor = [UIColor clearColor];
		viaLabel.text = @"via ";
		[self addSubview:viaLabel];
		
		size2 = [[NSString stringWithFormat:@"@%@ ", _vo.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viaLabel.frame.origin.x + size.width, 41.0, size2.width, size2.height)];
		handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		handleLabel.textColor = [UIColor whiteColor];
		handleLabel.backgroundColor = [UIColor clearColor];
		handleLabel.text = [NSString stringWithFormat:@"@%@ ", _vo.twitterHandle];
		[self addSubview:handleLabel];
		
		UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		handleButton.frame = handleLabel.frame;
		[self addSubview:handleButton];
		
		size = [@"into " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *inLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x + size2.width, 41.0, size.width, size.height)];
		inLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12];
		inLabel.textColor = [UIColor whiteColor];
		inLabel.backgroundColor = [UIColor clearColor];
		inLabel.text = @"into ";
		[self addSubview:inLabel];
		
		size2 = [[NSString stringWithFormat:@"%@", _vo.topicTitle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(inLabel.frame.origin.x + size.width, 41.0, size2.width, size2.height)];
		topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		topicLabel.textColor = [UIColor whiteColor];
		topicLabel.backgroundColor = [UIColor clearColor];
		topicLabel.text = [NSString stringWithFormat:@"%@", _vo.topicTitle];
		[self addSubview:topicLabel];
		
		
		UIButton *topicButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[topicButton addTarget:self action:@selector(_goTopic) forControlEvents:UIControlEventTouchUpInside];
		topicButton.frame = topicLabel.frame;
		[self addSubview:topicButton];
		
		if ([_vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
			_sub1ImgView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0, 260.0, 140.0, 140.0 * ((SNImageVO *)[_vo.images objectAtIndex:0]).ratio)];
			[_sub1ImgView setBackgroundColor:[UIColor whiteColor]];
			_sub1ImgView.userInteractionEnabled = YES;
			[self addSubview:_sub1ImgView];
			
			UITapGestureRecognizer *tap1Recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photo1ZoomIn:)];
			tap1Recognizer.numberOfTapsRequired = 1;
			[_sub1ImgView addGestureRecognizer:tap1Recognizer];
			
			_sub2ImgView = [[UIImageView alloc] initWithFrame:CGRectMake(161.0, 260.0, 140.0, 140.0 * ((SNImageVO *)[_vo.images objectAtIndex:0]).ratio)];
			[_sub2ImgView setBackgroundColor:[UIColor whiteColor]];
			_sub2ImgView.userInteractionEnabled = YES;
			[self addSubview:_sub2ImgView];
			
			UITapGestureRecognizer *tap2Recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photo2ZoomIn:)];
			tap2Recognizer.numberOfTapsRequired = 1;
			[_sub2ImgView addGestureRecognizer:tap2Recognizer];
		}
		
		
		_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButton.frame = CGRectMake(9.0, 367.0, 93.0, 43.0);
		[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		//[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUI_nonActive.png"] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUI_Active.png"] forState:UIControlStateHighlighted];
		[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		_likeButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, -2.0, -1.0);
		[_likeButton setTitle:[NSString stringWithFormat:@"Likes (%d)", _vo.totalLikes] forState:UIControlStateNormal];
		_likeButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, -5.0, -2.0, 5.0);
		[_likeButton setImage:[UIImage imageNamed:@"likeIcon.png"] forState:UIControlStateNormal];
		[_likeButton setImage:[UIImage imageNamed:@"likeIcon_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:_likeButton];
		
		if (_vo.hasLiked)
			[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		
		else
			[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		
//		if (_vo.totalLikes > 0) {
//			_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
//			[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
//		}
		
		
		//up = UIEdgeInsetsMake(-2.0, 0.0, 2.0, 0.0);
		//dn = UIEdgeInsetsMake(2.0, 0.0, -2.0, 0.0);
		//lt = UIEdgeInsetsMake(0.0, -2.0, 0.0, 2.0);
		//rt = UIEdgeInsetsMake(0.0, 2.0, 0.0, -2.0);
		
		_commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_commentButton.frame = CGRectMake(102.0, 367.0, 115.0, 43.0);
		//[_commentButton setBackgroundImage:[UIImage imageNamed:@"centerBottomUI_nonActive.png"] forState:UIControlStateNormal];
		[_commentButton setBackgroundImage:[UIImage imageNamed:@"centerBottomUI_Active.png"] forState:UIControlStateHighlighted];
		[_commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
		[_commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		_commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		_commentButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, -2.0, -1.0);
		[_commentButton setTitle:[NSString stringWithFormat:@"Comments (%d)", _vo.comments.count] forState:UIControlStateNormal];
		_commentButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, -5.0, -2.0, 5.0);
		[_commentButton setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
		[_commentButton setImage:[UIImage imageNamed:@"commentIcon_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:_commentButton];
		
//		if ([_vo.comments count] > 0) {
//			_commentButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
//			[_commentButton setTitle:[NSString stringWithFormat:@"%d", [_vo.comments count]] forState:UIControlStateNormal];
//		}
		
		
		UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
		sourceButton.frame = CGRectMake(217.0, 367.0, 93.0, 43.0);
		//[sourceButton setBackgroundImage:[[UIImage imageNamed:@"rightBottomUI_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[sourceButton setBackgroundImage:[[UIImage imageNamed:@"rightBottomUI_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		sourceButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, -2.0, -1.0);
		[sourceButton setImage:[UIImage imageNamed:@"moreIcon_nonActive.png"] forState:UIControlStateNormal];
		[sourceButton setImage:[UIImage imageNamed:@"moreIcon_Active.png"] forState:UIControlStateHighlighted];
		[sourceButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:sourceButton];
		
		
		if (_vo.totalLikes > 0) {
			int offset2 = 15;
			for (SNTwitterUserVO *tuVO in _vo.userLikes) {
				SNTwitterAvatarView *avatarView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(offset2, 332.0) imageURL:tuVO.avatarURL handle:tuVO.handle];
				[self addSubview:avatarView];
				offset2 += 31.0;
			}
		}		
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
		
		
		ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		likeRequest.delegate = self;
		[likeRequest startAsynchronous];
		
		_vo.hasLiked = YES;
	}
}

-(void)_goDislike {
	
	[_likeButton removeTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	
	ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
	[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	likeRequest.delegate = self;
	[likeRequest startAsynchronous];
	
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

-(void)_goVideo {
	[_videoButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:5]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		[_videoButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
		
	} completion:^(BOOL finished) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											  @"video", @"type", 
											  _vo, @"article_vo", 
											  [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
											  [NSValue valueWithCGRect:CGRectMake(_videoImgView.frame.origin.x + self.frame.origin.x, _videoImgView.frame.origin.y, _videoImgView.frame.size.width, _videoImgView.frame.size.height)], @"frame", nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];	
	}];
}

- (void)_goTopic {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TOPIC" object:[NSNumber numberWithInt:_vo.topicID]];
}

-(void)_goTwitterProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:_vo.twitterHandle];
}


-(void)_photoZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  @"photo", @"type", 
										  _vo, @"article_vo", 
										  (SNImageVO *)[_vo.images objectAtIndex:0], @"image_vo", 
										  [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
										  [NSValue valueWithCGRect:CGRectMake(_articleImgView.frame.origin.x + 5.0, _articleImgView.frame.origin.y + 8.0, _articleImgView.frame.size.width, _articleImgView.frame.size.height)], @"frame", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}

-(void)_photo1ZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  @"photo", @"type", 
										  _vo, @"article_vo", 
										  (SNImageVO *)[_vo.images objectAtIndex:0], @"image_vo", 
										  [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
										  [NSValue valueWithCGRect:CGRectMake(_sub1ImgView.frame.origin.x, _sub1ImgView.frame.origin.y, _sub1ImgView.frame.size.width, _sub1ImgView.frame.size.height)], @"frame", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}

-(void)_photo2ZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  @"photo", @"type", 
										  _vo, @"article_vo", 
										  (SNImageVO *)[_vo.images objectAtIndex:0], @"image_vo", 
										  [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
										  [NSValue valueWithCGRect:CGRectMake(_sub2ImgView.frame.origin.x, _sub2ImgView.frame.origin.y, _sub2ImgView.frame.size.width, _sub2ImgView.frame.size.height)], @"frame", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}



#pragma mark - Async Resource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	_articleImgView.image = [UIImage imageWithData:data];
	
	if ([_vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
		_sub1ImgView.image = [UIImage imageWithData:data];
		_sub2ImgView.image = [UIImage imageWithData:data];
	}
	//_articleImgView.image = [SNAppDelegate imageWithFilters:[UIImage imageWithData:data] filter:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"saturation", @"type", [NSNumber numberWithFloat:1.0], @"amount", nil], nil]];
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleItem_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	NSError *error = nil;
	NSDictionary *parsedLike = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
	
	if (error != nil)
		NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
	
	else {
		_vo.totalLikes = [[parsedLike objectForKey:@"likes"] intValue];
		[_likeButton setTitle:[NSString stringWithFormat:@"Likes (%d)", _vo.totalLikes] forState:UIControlStateNormal];
		
		if (_vo.totalLikes > 0) {
			//_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
			//[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
			
		} else {
			//_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			//[_likeButton setTitle:@"" forState:UIControlStateNormal];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
