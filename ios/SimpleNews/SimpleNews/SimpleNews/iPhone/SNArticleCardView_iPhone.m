//
//  SNArticleCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleCardView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNTagVO.h"

#import "EGOImageLoader.h"
#import "SNArticleFollowerInfoView_iPhone.h"

#import "SNReactionVO.h"
#import "SNArticleReactionItemView.h"

@interface SNArticleCardView_iPhone()
-(void)_goExpandCollapse:(id)sender;
-(void)_goPlayVideo;
-(void)_goReadMore;
@end

@implementation SNArticleCardView_iPhone

#define kImageScale 0.9
#define kBaseHeaderHeight 65.0

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo index:(int)idx {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeCards:) name:@"CHANGE_CARDS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		_vo = vo;
		_ind = idx;
		_isExpanded = NO;
		
		self.userInteractionEnabled = NO;
		[self setBackgroundColor:[UIColor clearColor]];
		
		_reactionViews = [NSMutableArray new];
		
		_tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_titleSize = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:22] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_contentSize = [_vo.content sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		int reactionsHeight = 50;
		for (SNReactionVO *vo in _vo.reactions)
			reactionsHeight += (30.0 + [vo.content sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip].height);
		
		EGOImageView *bgImageView = [[[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
		bgImageView.delegate = self;
		bgImageView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
		[_bgView addSubview:bgImageView];
		
		_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - kBaseHeaderHeight, _holderView.frame.size.width, _tweetSize.height + _titleSize.height + _contentSize.height + reactionsHeight + 250.0);
		_holderView.alpha = 0.0;
		
		_headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kBaseHeaderHeight)] autorelease];
		[_headerView setBackgroundColor:[UIColor colorWithWhite:0.094 alpha:1.0]];
		_headerView.alpha = 0.85;
		
		SNArticleFollowerInfoView_iPhone *articleFollowerView = [[[SNArticleFollowerInfoView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kBaseHeaderHeight) articleVO:_vo] autorelease];
		[_headerView addSubview:articleFollowerView];
		[_holderView addSubview:_headerView];
		
		_expandCollapseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_expandCollapseButton.frame = CGRectMake(284.0, 12.0, 24.0, 24.0);
		[_expandCollapseButton setBackgroundImage:[UIImage imageNamed:@"upDownArrow_nonActive.png"] forState:UIControlStateNormal];
		[_expandCollapseButton setBackgroundImage:[UIImage imageNamed:@"upDownArrow_Active.png"] forState:UIControlStateHighlighted];
		[_expandCollapseButton addTarget:self action:@selector(_goExpandCollapse:) forControlEvents:UIControlEventTouchUpInside];
		[_holderView addSubview:_expandCollapseButton];
		
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, kBaseHeaderHeight, self.bounds.size.width, self.bounds.size.height - kBaseHeaderHeight)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_scrollView setBackgroundColor:[UIColor colorWithWhite:0.137 alpha:1.0]];
		_scrollView.opaque = YES;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = NO;
		_scrollView.delegate = self;
		_scrollView.userInteractionEnabled = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width, _holderView.frame.size.height);
		[_holderView addSubview:_scrollView];
		
		if (_vo.type_id > 4) {
			_playButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			_playButton.frame = CGRectMake(121.0, 165.0, 84.0, 84.0);
			_playButton.alpha = 0.0;
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
			[_playButton addTarget:self action:@selector(_goPlayVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_playButton];
		}
		
				
		UIView *tweetBgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, _tweetSize.height + 45.0)] autorelease];
		[tweetBgView setBackgroundColor:[UIColor colorWithWhite:0.184 alpha:1.0]];
		[_scrollView addSubview:tweetBgView];
		
		UILabel *tweetLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 12.0, 296.0, _tweetSize.height)] autorelease];
		tweetLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		tweetLabel.textColor = [UIColor whiteColor];
		tweetLabel.backgroundColor = [UIColor clearColor];
		tweetLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		tweetLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		tweetLabel.text = _vo.tweetMessage;
		tweetLabel.numberOfLines = 0;
		[_scrollView addSubview:tweetLabel];
		
		
		UIButton *tweetButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		tweetButton.frame = tweetLabel.frame;
		[tweetButton addTarget:self action:@selector(_goTweetPage) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:tweetButton];
		
		UIImageView *twitterIcoImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(12.0, 17.0 + _tweetSize.height, 14.0, 14.0)] autorelease];
		twitterIcoImgView.image = [UIImage imageNamed:@"twitterIcon.png"];
		[_scrollView addSubview:twitterIcoImgView];
		
		UILabel *twitterSiteLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30.0, 17.0 + _tweetSize.height, 150.0, 16.0)] autorelease];
		twitterSiteLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12];
		twitterSiteLabel.textColor = [UIColor whiteColor];
		twitterSiteLabel.backgroundColor = [UIColor clearColor];
		twitterSiteLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		twitterSiteLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		twitterSiteLabel.text = @"Twitter.com";
		[_scrollView addSubview:twitterSiteLabel];
		
		UIView *iconsView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 45.0 + _tweetSize.height, self.frame.size.width, 53.0)] autorelease];
		[iconsView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
		[_scrollView addSubview:iconsView];
		
		UIButton *favoriteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		favoriteButton.frame = CGRectMake(90.0, 12.0, 34.0, 34.0);
		[favoriteButton setBackgroundImage:[UIImage imageNamed:@"star_nonActive.png"] forState:UIControlStateNormal];
		[favoriteButton setBackgroundImage:[UIImage imageNamed:@"star_Active.png"] forState:UIControlStateHighlighted];
		[favoriteButton addTarget:self action:@selector(_goFavorite) forControlEvents:UIControlEventTouchUpInside];
		[iconsView addSubview:favoriteButton];
		
		UIButton *shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		shareButton.frame = CGRectMake(143.0, 12.0, 34.0, 34.0);
		[shareButton setBackgroundImage:[UIImage imageNamed:@"shareIconB_nonActive.png"] forState:UIControlStateNormal];
		[shareButton setBackgroundImage:[UIImage imageNamed:@"shareIconB_Active.png"] forState:UIControlStateHighlighted];
		[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[iconsView addSubview:shareButton];
		
		UIButton *personButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		personButton.frame = CGRectMake(205.0, 12.0, 34.0, 34.0);
		[personButton setBackgroundImage:[UIImage imageNamed:@"viewPerson_nonActive.png"] forState:UIControlStateNormal];
		[personButton setBackgroundImage:[UIImage imageNamed:@"viewPerson_Active.png"] forState:UIControlStateHighlighted];
		[personButton addTarget:self action:@selector(_goPerson) forControlEvents:UIControlEventTouchUpInside];
		[iconsView addSubview:personButton];
		
		_iconsCoverImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 45.0 + _tweetSize.height, self.frame.size.width, 53.0)];
		_iconsCoverImgView.image = [UIImage imageNamed:@"storyShelfCover.png"];
		[_scrollView addSubview:_iconsCoverImgView];
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 123.0 + _tweetSize.height, 296.0, _titleSize.height)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:22];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		titleLabel.text = _vo.title;
		titleLabel.numberOfLines = 0;
		[_scrollView addSubview:titleLabel];
		
		UIButton *titleButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		titleButton.frame = titleLabel.frame;
		[titleButton addTarget:self action:@selector(_goSourcePage) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:titleButton];
		
		UILabel *contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 148.0 + _titleSize.height + _tweetSize.height, 296.0, _contentSize.height)] autorelease];
		contentLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		contentLabel.textColor = [UIColor whiteColor];
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		contentLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		contentLabel.text = _vo.content;
		contentLabel.numberOfLines = 0;
		[_scrollView addSubview:contentLabel];
		
		UIButton *readMoreBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		readMoreBtn.frame = CGRectMake(118.0, 168.0 + _titleSize.height + _tweetSize.height + _contentSize.height, 84.0, 34.0);
		[readMoreBtn setBackgroundImage:[UIImage imageNamed:@"readMoreButton_nonActive.png"] forState:UIControlStateNormal];
		[readMoreBtn setBackgroundImage:[UIImage imageNamed:@"readMoreButton_Active.png"] forState:UIControlStateHighlighted];
		readMoreBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
		readMoreBtn.titleLabel.textAlignment = UITextAlignmentCenter;
		[readMoreBtn setTitleColor:[UIColor colorWithWhite:0.773 alpha:1.0] forState:UIControlStateNormal];
		readMoreBtn.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		readMoreBtn.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		[readMoreBtn setTitle:@"Read More" forState:UIControlStateNormal];
		[readMoreBtn addTarget:self action:@selector(_goReadMore) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:readMoreBtn];
		
		UIView *reactionsView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 217.0 + _titleSize.height + _tweetSize.height + _contentSize.height, self.frame.size.width, 50.0 + reactionsHeight)] autorelease];
		[reactionsView setBackgroundColor:[UIColor colorWithWhite:0.176 alpha:1.0]];
		[_scrollView addSubview:reactionsView];
		
		UILabel *reactionsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 20.0, 250.0, 14.0)] autorelease];
		reactionsLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		reactionsLabel.textColor = [UIColor colorWithWhite:0.294 alpha:1.0];
		reactionsLabel.backgroundColor = [UIColor clearColor];
		reactionsLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		reactionsLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		reactionsLabel.text = @"REACTIONS";
		[reactionsView addSubview:reactionsLabel];
		
		int offset = 50;
		for (SNReactionVO *vo in _vo.reactions) {
			NSLog(@"OFFSET:%d", offset);
			
			CGSize txtSize = [vo.content sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
			
			SNArticleReactionItemView *reactionView = [[[SNArticleReactionItemView alloc] initWithFrame:CGRectMake(0.0, offset, _scrollView.frame.size.width, 30.0 + txtSize.height) reactionVO:vo] autorelease];
			[_reactionViews addObject:reactionView];
			[reactionsView addSubview:reactionView];
			
			offset += (30.0 + txtSize.height);
		}
		
		UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_goExpandCollapse:)];
		swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
		[self addGestureRecognizer:swipeUpRecognizer];
		[swipeUpRecognizer release];
		
		UISwipeGestureRecognizer *swipeDnRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(_goExpandCollapse:)];
		swipeDnRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
		[self addGestureRecognizer:swipeDnRecognizer];
		[swipeDnRecognizer release];
	}
	
	return (self);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"CHANGE_CARDS" object:nil];
	
	[_headerBgView release];
	[_headerView release];
	[_iconsCoverImgView release];
		
	[super dealloc];
}


//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	UITouch *touch = [touches anyObject];
//	
//	if ([touch view] == _bgView || [touch view] == _holderView) {
//		[self _goExpandCollapse:nil];
//		return;
//	}
//}

#pragma mark - Interaction handlers
-(void)resetContent {
	_isExpanded = NO;
	_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - kBaseHeaderHeight, _holderView.frame.size.width, _holderView.frame.size.height);
	_holderView.alpha = 0.0;
	_playButton.alpha = 0.0;
	_iconsCoverImgView.frame = CGRectMake(0.0, _iconsCoverImgView.frame.origin.y, _iconsCoverImgView.frame.size.width, _iconsCoverImgView.frame.size.height);
	
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.beginTime = CACurrentMediaTime();
	rotationAnimation.toValue = [NSNumber numberWithDouble:0.0];
	rotationAnimation.duration = 0.15;
	rotationAnimation.fillMode = kCAFillModeForwards;
	rotationAnimation.removedOnCompletion = NO;
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	[[_expandCollapseButton layer] addAnimation:rotationAnimation forKey:@"rotationAnimation"];
	
	[super resetContent];
}

-(void)introContent {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - (kBaseHeaderHeight + _tweetSize.height + 45.0), _holderView.frame.size.width, _holderView.frame.size.height);
		_holderView.alpha = 1.0;
		
		if (_vo.type_id > 4)
			_playButton.alpha = 1,0;
	
	} completion:^(BOOL finished) {
		self.userInteractionEnabled = YES;
	}];
	
	[super introContent];
}

-(void)setTweets:(NSMutableArray *)tweets {
	_tweets = tweets;
}


#pragma mark - Navigation
-(void)_goPlayVideo {	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO" object:_vo];
}

-(void)_goExpandCollapse:(id)sender {
	NSLog(@"_goExpandCollapse");
	
	_isExpanded = !_isExpanded;
	int ang;
	
	if (_isExpanded) {
		ang = 180;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_BUTTONS" object:nil];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_holderView.frame = CGRectMake(_holderView.frame.origin.x, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
		} completion:^(BOOL finished) {
			_scrollView.userInteractionEnabled = YES;
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_iconsCoverImgView.frame = CGRectMake(_iconsCoverImgView.frame.size.width, _iconsCoverImgView.frame.origin.y, _iconsCoverImgView.frame.size.width, _iconsCoverImgView.frame.size.height);
			}];
		}];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_playButton.alpha = 0.0;
		}];
	
	} else {
		ang = 0;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_BUTTONS" object:nil];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_iconsCoverImgView.frame = CGRectMake(0.0, _iconsCoverImgView.frame.origin.y, _iconsCoverImgView.frame.size.width, _iconsCoverImgView.frame.size.height);
		}];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - (kBaseHeaderHeight + _tweetSize.height + 45.0), _holderView.frame.size.width, _holderView.frame.size.height);
		
		} completion:^(BOOL finished) {
			_scrollView.userInteractionEnabled = NO;
			
			[UIView animateWithDuration:0.25 animations:^(void) {
				_playButton.alpha = 1.0;
			}];
		}];
	}
	
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.beginTime = CACurrentMediaTime();
	rotationAnimation.toValue = [NSNumber numberWithDouble:(M_PI / 180) * ang];
	rotationAnimation.duration = 0.33;
	rotationAnimation.fillMode = kCAFillModeForwards;
	rotationAnimation.removedOnCompletion = NO;
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	[[_expandCollapseButton layer] addAnimation:rotationAnimation forKey:@"rotationAnimation"];
	
//	CGAffineTransform transform = _expandCollapseButton.transform;
//	_expandCollapseButton.center = CGPointMake(_expandCollapseButton.frame.size.width * 0.5, _expandCollapseButton.frame.size.height * 0.5);
//	transform = CGAffineTransformRotate(transform, M_PI);
//	_expandCollapseButton.transform = transform;
}

-(void)_goReadMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SOURCE_PAGE" object:_vo.article_url];
}

-(void)_goFavorite {
	
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SHEET" object:_vo];
}

-(void)_goPerson {
	
}

-(void)_goTweetPage {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWEET_PAGE" object:[NSString stringWithFormat:@"https://twitter.com/#!/%@/status/%@/", _vo.twitterHandle, _vo.tweet_id]];
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@/status/%@/", _vo.twitterHandle, _vo.tweet_id]]];
}

-(void)_goSourcePage {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SOURCE_PAGE" object:_vo.article_url];
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_vo.article_url]];
}


#pragma mark - Notifications
-(void)_videoEnded:(NSNotification *)notification {
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {	
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}


#pragma mark - ImageLoader Delegates
-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	//NSLog(@"IMAGE LOADED:[%@]", imageView.imageURL);
}

-(void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
	NSLog(@"IMAGE LOAD FAIL");
}


@end
