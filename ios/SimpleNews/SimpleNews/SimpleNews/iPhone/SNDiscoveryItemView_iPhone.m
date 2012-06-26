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

- (SNArticleVO *)article
{
	return (SNArticleVO *)self.item;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_cardView = [[UIView alloc] initWithFrame:self.view.bounds];
	_cardView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_cardView];
	
	_backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 7.0, 308.0, 408.0)];
	_backgroundImageView.userInteractionEnabled = YES;
	[_cardView addSubview:_backgroundImageView];
		
	_mainImageHolderView = [[UIView alloc] initWithFrame:CGRectMake(9.0, 9.0, 290.0, 302.0)];
	_mainImageHolderView.backgroundColor = [UIColor colorWithWhite:0.882 alpha:1.0];
	_mainImageHolderView.clipsToBounds = YES;
	[_backgroundImageView addSubview:_mainImageHolderView];
	
	_articleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 290.0, 290.0)];
	_articleImgView.backgroundColor = [UIColor whiteColor];
	_articleImgView.userInteractionEnabled = YES;
	[_mainImageHolderView addSubview:_articleImgView];
		
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photoZoomIn:)];
	tapRecognizer.numberOfTapsRequired = 1;
	[_articleImgView addGestureRecognizer:tapRecognizer];
		
	UIView *titleBGView = [[UIView alloc] initWithFrame:CGRectMake(9.0, 9.0, 290.0, 52.0)];
	[titleBGView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
	titleBGView.userInteractionEnabled = YES;
	[_backgroundImageView addSubview:titleBGView];
				
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, 24.0, 250.0, 18.0)];
	_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13];
	_titleLabel.textColor = [UIColor whiteColor];
	_titleLabel.backgroundColor = [UIColor clearColor];
	[_cardView addSubview:_titleLabel];
		
	_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_likeButton.frame = CGRectMake(9.0, 366.0, 93.0, 43.0);
	[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	//[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUI_nonActive.png"] forState:UIControlStateNormal];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	//_likeButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, -2.0, -1.0);
	_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -5.0, 0.0, 5.0);
	[_likeButton setImage:[UIImage imageNamed:@"likeIcon.png"] forState:UIControlStateNormal];
	[_likeButton setImage:[UIImage imageNamed:@"likeIcon_Active.png"] forState:UIControlStateHighlighted];
	[_cardView addSubview:_likeButton];
		
	_commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentButton.frame = CGRectMake(102.0, 366.0, 115.0, 43.0);
	//[_commentButton setBackgroundImage:[UIImage imageNamed:@"centerBottomUI_nonActive.png"] forState:UIControlStateNormal];
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"centerBottomUI_Active.png"] forState:UIControlStateHighlighted];
	[_commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	[_commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	_commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	//_commentButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, -2.0, -1.0);
	_commentButton.imageEdgeInsets = UIEdgeInsetsMake(1.0, -5.0, -1.0, 5.0);
	[_commentButton setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
	[_commentButton setImage:[UIImage imageNamed:@"commentIcon_Active.png"] forState:UIControlStateHighlighted];
	[_cardView addSubview:_commentButton];
		
	UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sourceButton.frame = CGRectMake(217.0, 366.0, 93.0, 43.0);
	//[sourceButton setBackgroundImage:[[UIImage imageNamed:@"rightBottomUI_nonActive.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[sourceButton setBackgroundImage:[[UIImage imageNamed:@"rightBottomUI_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	sourceButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, -2.0, -1.0);
	[sourceButton setImage:[UIImage imageNamed:@"moreIcon_nonActive.png"] forState:UIControlStateNormal];
	[sourceButton setImage:[UIImage imageNamed:@"moreIcon_Active.png"] forState:UIControlStateHighlighted];
	[sourceButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[_cardView addSubview:sourceButton];	
}

- (void)_resetContentViews
{
	// Restores views to default state so they can be reconfigured based on the current article
	_mainImageHolderView.frame = CGRectMake(9.0, 9.0, 290.0, 302.0);
	
	[_videoMatteView removeFromSuperview];
	_videoMatteView = nil;
	[_videoImgView removeFromSuperview];
	_videoImgView = nil;
	[_videoButton removeFromSuperview];
	_videoButton = nil;
	[_sub1ImgHolderView removeFromSuperview];
	_sub1ImgHolderView = nil;
	[_sub1ImgView removeFromSuperview];
	_sub1ImgView = nil;
	[_sub2ImgHolderView removeFromSuperview];
	_sub2ImgHolderView = nil;
	[_sub2ImgView removeFromSuperview];
	_sub2ImgView = nil;
}

- (void)_refreshWithArticle:(SNArticleVO *)article
{
	[self _resetContentViews];
	
	NSString *cardBackgroundImageName = (article.totalLikes > 0) ? @"defaultCardDiscover_Likes.png" : @"defaultCardDiscover_noLikes.png";
	_backgroundImageView.image = [[UIImage imageNamed:cardBackgroundImageName] stretchableImageWithLeftCapWidth:0.0 topCapHeight:20.0];
	
	_titleLabel.text = article.title;
	[self _updateAttributionViewsWithArticle:article];
	
	// Load the first article image
	SNImageVO *firstImage = [article.images objectAtIndex:0];
	_articleImgView.frame = CGRectMake(0.0, 0.0, 290.0, 290.0 * firstImage.ratio);
	self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:firstImage.url forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration from now
	
	// Update likes button
	NSString *likeActiveImageName = (article.totalLikes == 0) ? @"leftBottomUIB_Active.png" : @"leftBottomUI_Active.png";
	[_likeButton setBackgroundImage:[UIImage imageNamed:likeActiveImageName] forState:UIControlStateHighlighted];
	[_likeButton setTitle:[NSString stringWithFormat:@"Likes (%d)", article.totalLikes] forState:UIControlStateNormal];
	SEL likeAction = (article.hasLiked ? @selector(_goDislike) : @selector(_goLike));
	[_likeButton addTarget:self action:likeAction forControlEvents:UIControlEventTouchUpInside];
	
	// Update comments count
	[_commentButton setTitle:[NSString stringWithFormat:@"Comments (%d)", article.comments.count] forState:UIControlStateNormal];
	
	// Update twitter avatars
	NSMutableArray *twitterAvatars = [NSMutableArray array];
	if (article.totalLikes > 0) {
		int offset2 = 15;
		int tot = 0;
		for (SNTwitterUserVO *tuVO in article.userLikes) {
			if (tot >= 9)
				break;
			
			SNTwitterAvatarView *avatarView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(offset2, 331.0) imageURL:tuVO.avatarURL handle:tuVO.handle];
			[twitterAvatars addObject:avatarView];
			offset2 += 31.0;
			tot++;
		}
	}
	[_twitterAvatars makeObjectsPerformSelector:@selector(removeFromSuperview)];
	_twitterAvatars = twitterAvatars;
	[_twitterAvatars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { [_cardView addSubview:obj]; }];
	
	// Check for different article types and reconfigure as needed
	if (article.type_id > 3) {
		_videoMatteView = [[UIView alloc] initWithFrame:CGRectMake(9.0, 9.0, 290.0, 344.0)];
		_videoMatteView.backgroundColor = [UIColor blackColor];
		[_backgroundImageView addSubview:_videoMatteView];
		
		_videoImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(9.0, 99.0, 290.0, 217.0)];
		_videoImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", article.video_url]];
		[_backgroundImageView addSubview:_videoImgView];
		
		_videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_videoButton.frame = _videoImgView.frame;
		[_videoButton addTarget:self action:@selector(_goVideo) forControlEvents:UIControlEventTouchUpInside];
		[_backgroundImageView addSubview:_videoButton];
		
		UIImageView *playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(120.0, 84.0, 64.0, 64.0)];
		playImgView.image = [UIImage imageNamed:@"playButton_nonActive.png"];
		[_videoImgView addSubview:playImgView];	
	}
	else if ([article.article_url rangeOfString:@"itunes.apple.com"].length > 0) { 
		_mainImageHolderView.frame = CGRectMake(9.0, 9.0, 290.0, 194.0);
		
		_sub1ImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(15.0, 214.0, 142.0, 95.0)];
		[_sub1ImgHolderView setBackgroundColor:[UIColor colorWithWhite:0.882 alpha:1.0]];
		_sub1ImgHolderView.clipsToBounds = YES;
		[_cardView addSubview:_sub1ImgHolderView];
		
		_sub1ImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 142.0, 95.0)];
		[_sub1ImgView setBackgroundColor:[UIColor whiteColor]];
		_sub1ImgView.userInteractionEnabled = YES;
		[_sub1ImgHolderView addSubview:_sub1ImgView];
		if (firstImage.ratio > 1.0)
			_sub1ImgView.frame = CGRectMake(35.0, 0.0, 70.0, 105.0);
		
		UITapGestureRecognizer *tap1Recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photo1ZoomIn:)];
		tap1Recognizer.numberOfTapsRequired = 1;
		[_sub1ImgView addGestureRecognizer:tap1Recognizer];
		
		_sub2ImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(162.0, 214.0, 142.0, 95.0)];
		[_sub2ImgHolderView setBackgroundColor:[UIColor colorWithWhite:0.882 alpha:1.0]];
		_sub2ImgHolderView.clipsToBounds = YES;
		[_cardView addSubview:_sub2ImgHolderView];
		
		_sub2ImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 142.0, 95.0)];
		[_sub2ImgView setBackgroundColor:[UIColor whiteColor]];
		_sub2ImgView.userInteractionEnabled = YES;
		[_sub2ImgHolderView addSubview:_sub2ImgView];
		
		SNImageVO *secondaryImage = [article.images objectAtIndex:2];
		if (secondaryImage.ratio > 1.0)
			_sub2ImgView.frame = CGRectMake(35.0, 0.0, 70.0, 105.0);
		
		UITapGestureRecognizer *tap2Recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_photo2ZoomIn:)];
		tap2Recognizer.numberOfTapsRequired = 1;
		[_sub2ImgView addGestureRecognizer:tap2Recognizer];
	}
}

- (void)_updateAttributionViewsWithArticle:(SNArticleVO *)article
{
	NSMutableArray *attributionViews = [NSMutableArray array];
	
	CGSize size = [@"via 	" sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, 41.0, size.width, size.height)];
	viaLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12];
	viaLabel.textColor = [UIColor whiteColor];
	viaLabel.backgroundColor = [UIColor clearColor];
	viaLabel.text = @"via ";
	[attributionViews addObject:viaLabel];
	
	CGSize size2 = [[NSString stringWithFormat:@"@%@ ", article.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viaLabel.frame.origin.x + size.width, 41.0, size2.width, size2.height)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	handleLabel.textColor = [UIColor whiteColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@ ", article.twitterHandle];
	[attributionViews addObject:handleLabel];
	
	UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	handleButton.frame = handleLabel.frame;
	[attributionViews addObject:handleButton];
	
	size = [@"into " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *inLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x + size2.width, 41.0, size.width, size.height)];
	inLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:12];
	inLabel.textColor = [UIColor whiteColor];
	inLabel.backgroundColor = [UIColor clearColor];
	inLabel.text = @"into ";
	[attributionViews addObject:inLabel];
	
	size2 = [[NSString stringWithFormat:@"%@", article.topicTitle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(inLabel.frame.origin.x + size.width, 41.0, size2.width, size2.height)];
	topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	topicLabel.textColor = [UIColor whiteColor];
	topicLabel.backgroundColor = [UIColor clearColor];
	topicLabel.text = [NSString stringWithFormat:@"%@", article.topicTitle];
	[attributionViews addObject:topicLabel];
	
	UIButton *topicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[topicButton addTarget:self action:@selector(_goTopic) forControlEvents:UIControlEventTouchUpInside];
	topicButton.frame = topicLabel.frame;
	[attributionViews addObject:topicButton];
	
	[_attributionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	_attributionViews = attributionViews;
	[_attributionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { [_cardView addSubview:obj]; }];
}

- (void)_goShare {
	SNArticleVO *article = [self article];
	if (article.type_id < 4)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_MAIN_SHARE_SHEET" object:article];
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUB_SHARE_SHEET" object:article];
}

- (void)setImageResource:(MBLAsyncResource *)imageResource {
	if (_imageResource != nil) {
		[_imageResource unsubscribe:self];
		_imageResource = nil;
	}
	
	_imageResource = imageResource;
	
	if (_imageResource != nil)
		[_imageResource subscribe:self];
}

#pragma mark - MBLPageItemViewController subclass

- (void)setItem:(id)item
{
	if (item != self.item) {
		[super setItem:item];
		[self _refreshWithArticle:(SNArticleVO *)item];
	}
}

static CGFloat clamp_alpha(CGFloat alpha)
{
	if (alpha > 1.0)
		alpha = 1.0;
	if (alpha < 0.0)
		alpha = 0.0;
	return alpha;
}

- (void)updateAnimationWithPercent:(float)percent appearing:(BOOL)appearing
{
	// Map the percentage to the position in the appearance or disappearance animation.
	CGFloat animationPosition = percent;
	if (!appearing)
		animationPosition = (1.0 - percent);
	
	UIView *animatingView = _cardView;
	
	// Fade in/out on transition
	if (appearing)
		animatingView.alpha = 0.5 + (0.5 * animationPosition);
	else
		animatingView.alpha = 1.0;
	
	// Add a "pop" by scaling down offscreen images
	if (appearing) {
		CGFloat scalePosition = fmaxf(animationPosition - 0.95, 0.0);
		CGFloat scaleFactor = fminf(0.85 + (3.0 * scalePosition), 1.0);
		animatingView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
	}
	else {
		animatingView.transform = CGAffineTransformIdentity;
	}
}

- (void)pageItemViewWasPlacedOffscreen
{
	[self _resetContentViews];
	_cardView.transform = CGAffineTransformMakeScale(0.85, 0.85);
}

- (void)pageItemViewDidBecomeFocusAnimated:(BOOL)animated
{
}

#pragma mark - Navigation

- (void)_goLike {
	SNArticleVO *article = [self article];
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
	} else {		
		[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		
		
		ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
		[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[likeRequest setPostValue:[NSString stringWithFormat:@"%d", article.article_id] forKey:@"articleID"];
		likeRequest.delegate = self;
		[likeRequest startAsynchronous];
		
		article.hasLiked = YES;
	}
}

- (void)_goDislike {
	SNArticleVO *article = [self article];
	[_likeButton removeTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	
	
	ASIFormDataRequest *likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles2.php"]]];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
	[likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[likeRequest setPostValue:[NSString stringWithFormat:@"%d", article.article_id] forKey:@"articleID"];
	likeRequest.delegate = self;
	[likeRequest startAsynchronous];
	
	article.hasLiked = NO;
}

- (void)_goComments {
	SNArticleVO *article = [self article];
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
	} else {		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_COMMENTS" object:article];
	}
}

- (void)_goVideo {
	[_videoButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:5]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		[_videoButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
		
	} completion:^(BOOL finished) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											  @"video", @"type", 
											  self.article, @"article_vo", 
											  [NSNumber numberWithFloat:self.view.frame.origin.y], @"offset", 
											  [NSValue valueWithCGRect:CGRectMake(_videoImgView.frame.origin.x + self.view.frame.origin.x, _videoImgView.frame.origin.y, _videoImgView.frame.size.width, _videoImgView.frame.size.height)], @"frame", nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];	
	}];
}

- (void)_goTopic {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TOPIC" object:[NSNumber numberWithInt:self.article.topicID]];
}

- (void)_goTwitterProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:self.article.twitterHandle];
}


- (void)_photoZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	SNArticleVO *article = [self article];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  @"photo", @"type", 
										  article, @"article_vo", 
										  [article.images objectAtIndex:0], @"image_vo", 
										  [NSNumber numberWithFloat:self.view.frame.origin.y], @"offset", 
										  [NSValue valueWithCGRect:CGRectMake(_articleImgView.frame.origin.x + 15.0, _articleImgView.frame.origin.y + 15.0, _articleImgView.frame.size.width, _articleImgView.frame.size.height)], @"frame", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}

- (void)_photo1ZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	SNArticleVO *article = [self article];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  @"photo", @"type", 
										  article, @"article_vo", 
										  [article.images objectAtIndex:1], @"image_vo", 
										  [NSNumber numberWithFloat:self.view.frame.origin.y], @"offset", 
										  [NSValue valueWithCGRect:CGRectMake(_sub1ImgHolderView.frame.origin.x, _sub1ImgHolderView.frame.origin.y, _sub1ImgHolderView.frame.size.width, _sub1ImgHolderView.frame.size.height)], @"frame", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}

- (void)_photo2ZoomIn:(UIGestureRecognizer *)gestureRecognizer {
	SNArticleVO *article = [self article];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  @"photo", @"type", 
										  article, @"article_vo", 
										  [article.images objectAtIndex:2], @"image_vo", 
										  [NSNumber numberWithFloat:self.view.frame.origin.y], @"offset", 
										  [NSValue valueWithCGRect:CGRectMake(_sub2ImgHolderView.frame.origin.x, _sub2ImgHolderView.frame.origin.y, _sub2ImgHolderView.frame.size.width, _sub2ImgHolderView.frame.size.height)], @"frame", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FULLSCREEN_MEDIA" object:dict];
}

#pragma mark - Async Resource Observers

- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	_articleImgView.image = [UIImage imageWithData:data];
	
	if ([self.article.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
		_sub1ImgView.image = [UIImage imageWithData:data];
		_sub2ImgView.image = [UIImage imageWithData:data];
	}
	//_articleImgView.image = [SNAppDelegate imageWithFilters:[UIImage imageWithData:data] filter:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"saturation", @"type", [NSNumber numberWithFloat:1.0], @"amount", nil], nil]];
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
}

#pragma mark - ASI Delegates

- (void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNArticleItem_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	NSError *error = nil;
	NSDictionary *parsedLike = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
	
	if (error != nil) {
		NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
	}
	else {
		SNArticleVO *article = [self article];
		article.totalLikes = [[parsedLike objectForKey:@"likes"] intValue];
		[_likeButton setTitle:[NSString stringWithFormat:@"Likes (%d)", article.totalLikes] forState:UIControlStateNormal];
		
		if (article.totalLikes > 0) {
			//_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0);
			//[_likeButton setTitle:[NSString stringWithFormat:@"%d", _vo.totalLikes] forState:UIControlStateNormal];
			
		} else {
			//_likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			//[_likeButton setTitle:@"" forState:UIControlStateNormal];
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
