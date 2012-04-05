//
//  SNArticleCardView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNArticleCardView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNTagVO.h"

#import "EGOImageLoader.h"
#import "SNArticleInfluencerInfoView_iPhone.h"

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
		
		//_tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_titleSize = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:22] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_contentSize = [_vo.content sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		int reactionsHeight = 50;
		for (SNReactionVO *vo in _vo.reactions)
			reactionsHeight += (30.0 + [vo.content sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip].height);
		
		EGOImageView *bgImageView = [[[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
		bgImageView.delegate = self;
		bgImageView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
		[_bgView addSubview:bgImageView];
		
		//UIImageView *testImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
		//testImgView.image = [UIImage imageNamed:@"storyImageTest.jpg"];
		//[_bgView addSubview:testImgView];
		
		_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - kBaseHeaderHeight, _holderView.frame.size.width, _titleSize.height + _contentSize.height + reactionsHeight + 150.0);
		_holderView.alpha = 0.0;
		
		SNArticleInfluencerInfoView_iPhone *_articleInfluencerView = [[[SNArticleInfluencerInfoView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kBaseHeaderHeight) articleVO:_vo] autorelease];
		[_holderView addSubview:_articleInfluencerView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, kBaseHeaderHeight, self.bounds.size.width, self.bounds.size.height - kBaseHeaderHeight)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_scrollView setBackgroundColor:[UIColor whiteColor]];
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
		
		UIImageView *inputBgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 54.0, self.frame.size.width, 54.0)] autorelease];
		inputBgImgView.image = [UIImage imageNamed:@"inputFieldBG.png"];
		inputBgImgView.userInteractionEnabled = YES;
		[_holderView addSubview:inputBgImgView];
		
		UITextField *commentTxtField = [[[UITextField alloc] initWithFrame:CGRectMake(23.0, 21.0, 270.0, 16.0)] autorelease];
		[commentTxtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[commentTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[commentTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[commentTxtField setBackgroundColor:[UIColor clearColor]];
		[commentTxtField setReturnKeyType:UIReturnKeyDone];
		[commentTxtField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		commentTxtField.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12];
		commentTxtField.keyboardType = UIKeyboardTypeDefault;
		commentTxtField.text = @"";
		commentTxtField.placeholder = @"Comment";
		[inputBgImgView addSubview:commentTxtField];
		
//		UIButton *emoticonButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//		emoticonButton.frame = CGRectMake(280.0, 13.0, 24.0, 24.0);
//		[emoticonButton setBackgroundImage:[UIImage imageNamed:@"emoticon_nonActive.png"] forState:UIControlStateNormal];
//		[emoticonButton setBackgroundImage:[UIImage imageNamed:@"emoticon_Active.png"] forState:UIControlStateHighlighted];
//		[emoticonButton addTarget:self action:@selector(_goEmoticon) forControlEvents:UIControlEventTouchUpInside];
//		[inputBgImgView addSubview:emoticonButton];
		
		
		UIImageView *scoreBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(261.0, 35.0, 64.0, 94.0)];
		scoreBgImgView.image = [UIImage imageNamed:@"scoreMeterBG.png"];
		scoreBgImgView.userInteractionEnabled = YES;
		[self addSubview:scoreBgImgView];
		
		UIButton *scoreFavoriteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		scoreFavoriteButton.frame = CGRectMake(22.0, 18.0, 24.0, 24.0);
		[scoreFavoriteButton setBackgroundImage:[UIImage imageNamed:@"likeIcon_nonActive.png"] forState:UIControlStateNormal];
		[scoreFavoriteButton setBackgroundImage:[UIImage imageNamed:@"likeIcon_Active.png"] forState:UIControlStateHighlighted];
		[scoreFavoriteButton addTarget:self action:@selector(_goFavorite) forControlEvents:UIControlEventTouchUpInside];
		[scoreBgImgView addSubview:scoreFavoriteButton];
		
		UIButton *scoreShareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		scoreShareButton.frame = CGRectMake(22.0, 58.0, 24.0, 24.0);
		[scoreShareButton setBackgroundImage:[UIImage imageNamed:@"shareIconB_nonActive.png"] forState:UIControlStateNormal];
		[scoreShareButton setBackgroundImage:[UIImage imageNamed:@"shareIconB_Active.png"] forState:UIControlStateHighlighted];
		[scoreShareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[scoreBgImgView addSubview:scoreShareButton];
		
		_collapseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_collapseButton.frame = CGRectMake(320.0, -64.0, 64.0, 64.0);
		[_collapseButton setBackgroundImage:[UIImage imageNamed:@"topLeftClose_nonActive.png"] forState:UIControlStateNormal];
		[_collapseButton setBackgroundImage:[UIImage imageNamed:@"topLeftClose_Active.png"] forState:UIControlStateHighlighted];
		[_collapseButton addTarget:self action:@selector(_goExpandCollapse:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_collapseButton];
		
		if (_vo.type_id > 4) {
			_playButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			_playButton.frame = CGRectMake(121.0, 165.0, 84.0, 84.0);
			_playButton.alpha = 0.0;
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
			[_playButton addTarget:self action:@selector(_goPlayVideo) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_playButton];
		}
		
		/*		
		UIView *tweetBgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, _tweetSize.height + 45.0)] autorelease];
		[tweetBgView setBackgroundColor:[UIColor whiteColor]];
		[_scrollView addSubview:tweetBgView];
		
		UILabel *tweetLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 12.0, 296.0, _tweetSize.height)] autorelease];
		tweetLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		tweetLabel.textColor = [UIColor colorWithWhite:0.243 alpha:1.0];
		tweetLabel.backgroundColor = [UIColor clearColor];
		tweetLabel.text = _vo.tweetMessage;
		tweetLabel.numberOfLines = 0;
		[_scrollView addSubview:tweetLabel];
		
		UIButton *tweetButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		tweetButton.frame = tweetLabel.frame;
		[tweetButton addTarget:self action:@selector(_goTweetPage) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:tweetButton];
		*/
		
		//UIImageView *socialIconImgView;
		//UILabel *socialLabel;
		
		UIImageView *iconsBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 54.0)];
		iconsBgImgView.image = [UIImage imageNamed:@"shareBackground.png"];
		iconsBgImgView.userInteractionEnabled = YES;
		[_scrollView addSubview:iconsBgImgView];
		
		UIButton *favoriteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		favoriteButton.frame = CGRectMake(90.0, 12.0, 24.0, 24.0);
		[favoriteButton setBackgroundImage:[UIImage imageNamed:@"likeIcon_nonActive.png"] forState:UIControlStateNormal];
		[favoriteButton setBackgroundImage:[UIImage imageNamed:@"likeIcon_Active.png"] forState:UIControlStateHighlighted];
		[favoriteButton addTarget:self action:@selector(_goFavorite) forControlEvents:UIControlEventTouchUpInside];
		[iconsBgImgView addSubview:favoriteButton];
		
		UIButton *shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		shareButton.frame = CGRectMake(143.0, 12.0, 24.0, 24.0);
		[shareButton setBackgroundImage:[UIImage imageNamed:@"shareIconB_nonActive.png"] forState:UIControlStateNormal];
		[shareButton setBackgroundImage:[UIImage imageNamed:@"shareIconB_Active.png"] forState:UIControlStateHighlighted];
		[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[iconsBgImgView addSubview:shareButton];
		
		UIButton *personButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		personButton.frame = CGRectMake(205.0, 12.0, 24.0, 24.0);
		[personButton setBackgroundImage:[UIImage imageNamed:@"viewPerson_nonActive.png"] forState:UIControlStateNormal];
		[personButton setBackgroundImage:[UIImage imageNamed:@"viewPerson_Active.png"] forState:UIControlStateHighlighted];
		[personButton addTarget:self action:@selector(_goPerson) forControlEvents:UIControlEventTouchUpInside];
		[iconsBgImgView addSubview:personButton];
		
		_iconsCoverView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 54.0)];
		[_iconsCoverView setBackgroundColor:[UIColor whiteColor]];
		[_scrollView addSubview:_iconsCoverView];
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 73.0, 296.0, _titleSize.height)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:22];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = _vo.title;
		titleLabel.numberOfLines = 0;
		[_scrollView addSubview:titleLabel];
		
		UIButton *titleButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
		titleButton.frame = titleLabel.frame;
		//[titleButton addTarget:self action:@selector(_goSourcePage) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:titleButton];
		
		UILabel *contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 103.0 + _titleSize.height, 296.0, _contentSize.height)] autorelease];
		contentLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:16];
		contentLabel.textColor = [UIColor colorWithWhite:0.431 alpha:1.0];
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.text = _vo.content;
		contentLabel.numberOfLines = 0;
		[_scrollView addSubview:contentLabel];
		
		UIButton *readMoreBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		readMoreBtn.frame = CGRectMake(118.0, 110.0 + _titleSize.height + _contentSize.height, 84.0, 34.0);
		[readMoreBtn setBackgroundImage:[UIImage imageNamed:@"readMoreButton_nonActive.png"] forState:UIControlStateNormal];
		[readMoreBtn setBackgroundImage:[UIImage imageNamed:@"readMoreButton_Active.png"] forState:UIControlStateHighlighted];
		readMoreBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
		readMoreBtn.titleLabel.textAlignment = UITextAlignmentCenter;
		[readMoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[readMoreBtn setTitle:@"Read More" forState:UIControlStateNormal];
		[readMoreBtn addTarget:self action:@selector(_goReadMore) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:readMoreBtn];
		
		UIImageView *commentsBGImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 150.0 + _titleSize.height + _contentSize.height, self.frame.size.width, 480.0)] autorelease];
		commentsBGImgView.image = [UIImage imageNamed:@"background_plain.png"];
		[_scrollView addSubview:commentsBGImgView];
		
		
		int offset = 50;
		for (SNReactionVO *vo in _vo.reactions) {
			//NSLog(@"OFFSET:%d", offset);
			
			CGSize txtSize = [vo.content sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
			
			SNArticleReactionItemView *reactionView = [[[SNArticleReactionItemView alloc] initWithFrame:CGRectMake(0.0, offset, _scrollView.frame.size.width, 30.0 + txtSize.height) reactionVO:vo] autorelease];
			[_reactionViews addObject:reactionView];
			[commentsBGImgView addSubview:reactionView];
			
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
	[_iconsCoverView release];
		
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
	_iconsCoverView.frame = CGRectMake(0.0, _iconsCoverView.frame.origin.y, _iconsCoverView.frame.size.width, _iconsCoverView.frame.size.height);
	
	[super resetContent];
}

-(void)introContent {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - (kBaseHeaderHeight + 5.0), _holderView.frame.size.width, _holderView.frame.size.height);
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


-(void)_onTxtDoneEditing:(id)sender {
	[sender resignFirstResponder];
	
	//_titleLabel.text = _titleInputTxtField.text;
	//_commentLabel.text = _commentInputTxtView.text;
	
	//_holderView.hidden = NO;
	//_txtInputView.hidden = YES;
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
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_holderView.frame = CGRectMake(_holderView.frame.origin.x, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
		} completion:^(BOOL finished) {
			_scrollView.userInteractionEnabled = YES;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"STOP_TIMER" object:nil];
			[UIView animateWithDuration:0.33 animations:^(void) {
				_collapseButton.frame = CGRectMake(256.0, 0.0, 64.0, 64.0);
			} completion:nil];
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_iconsCoverView.frame = CGRectMake(_iconsCoverView.frame.size.width, _iconsCoverView.frame.origin.y, _iconsCoverView.frame.size.width, _iconsCoverView.frame.size.height);
			}];
		}];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_playButton.alpha = 0.0;
		}];
	
	} else {
		ang = 0;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"START_TIMER" object:nil];
		[UIView animateWithDuration:0.33 animations:^(void) {
			_collapseButton.frame = CGRectMake(320.0, -64.0, 64.0, 64.0);
		} completion:nil];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_iconsCoverView.frame = CGRectMake(0.0, _iconsCoverView.frame.origin.y, _iconsCoverView.frame.size.width, _iconsCoverView.frame.size.height);
		}];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - (kBaseHeaderHeight), _holderView.frame.size.width, _holderView.frame.size.height);
		
		} completion:^(BOOL finished) {
			_scrollView.userInteractionEnabled = NO;
			
			[UIView animateWithDuration:0.25 animations:^(void) {
				_playButton.alpha = 1.0;
			}];
		}];
	}
	
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

-(void)_goEmoticon {
	
}


#pragma mark - Notifications
-(void)_videoEnded:(NSNotification *)notification {
}


#pragma mark - TextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
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
