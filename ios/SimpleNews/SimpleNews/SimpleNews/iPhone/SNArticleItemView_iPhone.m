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
#import "SNTwitterAvatarView.h"
#import "SNArticleVideoPlayerView_iPhone.h"
#import "SNImageVO.h"
#import "SNTwitterUserVO.h"

@interface SNArticleItemView_iPhone () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *imageResource;
- (void)_showFSImage;
- (void)_showFSVideo;
@end

@implementation SNArticleItemView_iPhone

@synthesize imageResource = _imageResource;
@synthesize isFirstAppearance = _isFirstAppearance;

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		_isFirstAppearance = YES;
		
		int offset = 14;
		CGSize size;
		CGSize size2;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_commentAdded:) name:@"COMMENT_ADDED" object:nil];
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-10.0, 0.0, 320.0, frame.size.height)];
		UIImage *img = [UIImage imageNamed:@"timelineDiscoverBG.png"];
		bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:20.0];
		[self addSubview:bgImgView];
		
		SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(5.0, 7.0) imageURL:_vo.avatarImage_url];
		[[avatarImgView btn] addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarImgView];
		
		size = [@"via 	" sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(37.0, offset, size.width, size.height)];
		viaLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11];
		viaLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		viaLabel.backgroundColor = [UIColor clearColor];
		viaLabel.text = @"via ";
		[self addSubview:viaLabel];
		
		size2 = [[NSString stringWithFormat:@"@%@ ", _vo.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viaLabel.frame.origin.x + size.width, offset, size2.width, size2.height)];
		handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		handleLabel.textColor = [SNAppDelegate snLinkColor];
		handleLabel.backgroundColor = [UIColor clearColor];
		handleLabel.text = [NSString stringWithFormat:@"@%@ ", _vo.twitterHandle];
		[self addSubview:handleLabel];
		
		UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
		handleButton.frame = handleLabel.frame;
		[self addSubview:handleButton];
		
		size = [@"into " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *inLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x + size2.width, offset, size.width, size.height)];
		inLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11];
		inLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		inLabel.backgroundColor = [UIColor clearColor];
		inLabel.text = @"into ";
		[self addSubview:inLabel];
		
		size2 = [[NSString stringWithFormat:@"%@", _vo.topicTitle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(inLabel.frame.origin.x + size.width, offset, size2.width, size2.height)];
		topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		topicLabel.textColor = [SNAppDelegate snLinkColor];
		topicLabel.backgroundColor = [UIColor clearColor];
		topicLabel.text = [NSString stringWithFormat:@"%@", _vo.topicTitle];
		[self addSubview:topicLabel];
		
		
		UIButton *topicButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[topicButton addTarget:self action:@selector(_goTopic) forControlEvents:UIControlEventTouchUpInside];
		topicButton.frame = topicLabel.frame;
		[self addSubview:topicButton];
		
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
		
		size = [timeSince sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(265.0, offset + 1.0, size.width, size.height)];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
		dateLabel.textColor = [SNAppDelegate snGreyColor];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textAlignment = UITextAlignmentRight;
		dateLabel.text = timeSince;
		[self addSubview:dateLabel];
		
		offset += 29;
		
		if (!(_vo.topicID == 8)) {
			size = [_vo.title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:13] constrainedToSize:CGSizeMake(260.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, offset, 260.0, size.height)];
			titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:13];
			titleLabel.textColor = [SNAppDelegate snGreyColor];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.text = _vo.title;
			titleLabel.numberOfLines = 0;
			[self addSubview:titleLabel];
			
			UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[titleButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
			titleButton.frame = titleLabel.frame;
			[self addSubview:titleButton];
			
			offset += size.height + 6.0;
		}
		
		
		CGRect imgFrame = CGRectMake(5, offset, 290.0, 290.0 * ((SNImageVO *)[_vo.images objectAtIndex:0]).ratio);
//		if (_vo.topicID == 1 || _vo.topicID == 2) {
//			imgFrame.origin.x = 2.0;
//			imgFrame.size.width = 296.0;
//			imgFrame.size.height = 296.0 * _vo.imgRatio;
//		}
			
		
		if (_vo.type_id == 2 || _vo.type_id == 3) {
//			UIImageView *shadowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-10.0, (imgFrame.origin.y + imgFrame.size.height) - 53.0, 319.0, 64.0)];
//			shadowImgView.image = [UIImage imageNamed:@"imageDropShadow.png"];
//			[self addSubview:shadowImgView];
			
			_article1ImgView = [[UIImageView alloc] initWithFrame:imgFrame];
			[_article1ImgView setBackgroundColor:[UIColor whiteColor]];
			_article1ImgView.userInteractionEnabled = YES;
			[self addSubview:_article1ImgView];
			
			_imgOverlayView = [[UIView alloc] initWithFrame:imgFrame];
			[_imgOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
			[self addSubview:_imgOverlayView];
			
			UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photoZoomIn:)];
			tapRecognizer.numberOfTapsRequired = 1;
			[_imgOverlayView addGestureRecognizer:tapRecognizer];
			
			if (_imageResource == nil) {			
				self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:((SNImageVO *)[_vo.images objectAtIndex:0]).url forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration from now
			}
			
			if ([_vo.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
				_article1ImgView.frame = CGRectMake(5.0, offset, 140.0, 140.0 * ((SNImageVO *)[_vo.images objectAtIndex:0]).ratio);
				
				imgFrame = CGRectMake(155.0, offset, 140.0, 140.0 * ((SNImageVO *)[_vo.images objectAtIndex:0]).ratio);
				_article2ImgView = [[UIImageView alloc] initWithFrame:imgFrame];
				[_article2ImgView setBackgroundColor:[UIColor whiteColor]];
				_article2ImgView.userInteractionEnabled = YES;
				[self addSubview:_article2ImgView];
				
//				UIButton *itunesButton = [UIButton buttonWithType:UIButtonTypeCustom];
//				itunesButton.frame = CGRectMake(103.0, imgFrame.origin.y + ((imgFrame.size.height * 0.5) - 22.0), 114.0, 44.0);
//				[itunesButton setBackgroundImage:[UIImage imageNamed:@"availableOnAppStoreBadge_nonActive.png"] forState:UIControlStateNormal];
//				[itunesButton setBackgroundImage:[UIImage imageNamed:@"availableOnAppStoreBadge_Active.png"] forState:UIControlStateHighlighted];
//				[itunesButton addTarget:self action:@selector(_goAppStore) forControlEvents:UIControlEventTouchUpInside];
//				[self addSubview:itunesButton];
			}
			
			offset += (imgFrame.size.width * ((SNImageVO *)[_vo.images objectAtIndex:0]).ratio);
			offset += 9;
		}
		
		if (_vo.type_id > 3) {			
//			UIImageView *shadowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-10.0, (offset + 229.0) - 53.0, 319.0, 64.0)];
//			shadowImgView.image = [UIImage imageNamed:@"imageDropShadow.png"];
//			[self addSubview:shadowImgView];
			
			_videoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(5.0, offset, 290.0, 217.0)];
			_videoImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _vo.video_url]];
			[self addSubview:_videoImgView];
			
			_videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_videoButton.frame = _videoImgView.frame;
			[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_videoButton];
			
			UIImageView *playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(120.0, 82.0, 64.0, 64.0)];
			playImgView.image = [UIImage imageNamed:@"playButton.png"];
			[_videoImgView addSubview:playImgView];
			
			offset += 217;
			offset += 27;
		}
		
		_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButton.frame = CGRectMake(0.0, offset, 93.0, 43.0);
		[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUI_nonActive.png"] forState:UIControlStateNormal];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUI_Active.png"] forState:UIControlStateHighlighted];
		[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:10.0];
		[_likeButton setImage:[UIImage imageNamed:@"likeIcon.png"] forState:UIControlStateNormal];
		[_likeButton setImage:[UIImage imageNamed:@"likeIcon_Active.png"] forState:UIControlStateHighlighted];
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
		_commentButton.frame = CGRectMake(93.0, offset, 114.0, 43.0);
		[_commentButton setBackgroundImage:[UIImage imageNamed:@"centerBottomUI_nonActive.png"] forState:UIControlStateNormal];
		[_commentButton setBackgroundImage:[UIImage imageNamed:@"centerBottomUI_Active.png"] forState:UIControlStateHighlighted];
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
		sourceButton.frame = CGRectMake(207.0, offset, 93.0, 43.0);
		[sourceButton setBackgroundImage:[[UIImage imageNamed:@"rightBottomUI_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[sourceButton setBackgroundImage:[[UIImage imageNamed:@"rightBottomUI_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[sourceButton setImage:[UIImage imageNamed:@"moreIcon_nonActive.png"] forState:UIControlStateNormal];
		[sourceButton setImage:[UIImage imageNamed:@"moreIcon_Active.png"] forState:UIControlStateHighlighted];
		[sourceButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:sourceButton];
	}
	
	return (self);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEO_ENDED" object:nil];
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
-(void)_goDetails {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_DETAILS" object:_vo];
}

- (void)_goTopic {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TOPIC" object:[NSNumber numberWithInt:_vo.topicID]];
}

-(void)_goVideo {
	[_videoButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:5]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		[_videoButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
		
	} completion:^(BOOL finished) {
		[self _showFSVideo];	
	}];
}

-(void)_photoZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	[_imgOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:5]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		[_imgOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
		
	} completion:^(BOOL finished) {
		[self _showFSImage];	
	}];
}


-(void)_goSourcePage {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SOURCE_PAGE" object:_vo];
}

-(void)_goLike {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	
	} else {		
		[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		
		_likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		_likeRequest.delegate = self;
		[_likeRequest startAsynchronous];
		
		_vo.hasLiked = YES;
	}
}

-(void)_goDislike {
	
	[_likeButton removeTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	_likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
	[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
	[_likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
	_likeRequest.delegate = self;
	[_likeRequest startAsynchronous];
	
	_vo.hasLiked = NO;
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHEET" object:_vo];
}


-(void)_goComments {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
	} else {		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_COMMENTS" object:_vo];
	}
}


-(void)_goTwitterProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:_vo.twitterHandle];
}

- (void)_goAppStore {
	[SNAppDelegate openWithAppStore:_vo.article_url];
}

#pragma mark - Animations
- (void)_showFSVideo {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"video", @"type", 
								 _vo, @"VO", 
								 [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
								 [NSValue valueWithCGRect:CGRectMake(_videoImgView.frame.origin.x + self.frame.origin.x, _videoImgView.frame.origin.y, _videoImgView.frame.size.width, _videoImgView.frame.size.height)], @"frame", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}

- (void)_showFSImage {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"photo", @"type", 
								 _vo, @"VO", 
								 [NSNumber numberWithFloat:self.frame.origin.y], @"offset", 
								 [NSValue valueWithCGRect:CGRectMake(_article1ImgView.frame.origin.x + self.frame.origin.x, _article1ImgView.frame.origin.y, _article1ImgView.frame.size.width, _article1ImgView.frame.size.height)], @"frame", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}

#pragma mark - Notification handlers
-(void)_videoEnded:(NSNotification *)notification {
	[self addSubview:_videoButton];
	[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Notification handlers
-(void)_commentAdded:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	if (vo.article_id == _vo.article_id) {
		NSLog(@"COMMENT ADDED FOR “%@”", _vo.title);
		_commentButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
		[_commentButton setTitle:[NSString stringWithFormat:@"%d", [_vo.comments count]] forState:UIControlStateNormal];
	}
}


#pragma mark - Async Resource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	_article1ImgView.image = [UIImage imageWithData:data];
	_article2ImgView.image = [UIImage imageWithData:data];
	//_articleImgView.image = [SNAppDelegate imageWithFilters:[UIImage imageWithData:data] filter:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"saturation", @"type", [NSNumber numberWithFloat:1.0], @"amount", nil], nil]];
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleItem_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:_likeRequest]) {
		NSError *error = nil;
		NSDictionary *parsedLike = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			_vo.totalLikes = [[parsedLike objectForKey:@"likes"] intValue];
			[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
			
			if (_vo.totalLikes > 0) {
				_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
				[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
			
			} else {
				_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
				[_likeButton setTitle:@"" forState:UIControlStateNormal];
			}
		}
		
	}
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
