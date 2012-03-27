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

@interface SNArticleCardView_iPhone()
@end

@implementation SNArticleCardView_iPhone

#define kImageScale 0.9
#define kBaseHeaderHeight 65.0

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo index:(int)idx {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeCards:) name:@"CHANGE_CARDS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		_vo = vo;
		_isAtTop = NO;
		_ind = idx;
		_isExpanded = NO;
		
		self.userInteractionEnabled = NO;
		[self setBackgroundColor:[UIColor clearColor]];
		
		_tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_titleSize = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:22] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_contentSize = [_vo.content sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		EGOImageView *bgImageView = [[[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
		bgImageView.delegate = self;
		bgImageView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
		[_bgView addSubview:bgImageView];
		
		_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - kBaseHeaderHeight, _holderView.frame.size.width, _tweetSize.height + _titleSize.height + _contentSize.height + 150.0);
		_holderView.alpha = 0.0;
		
		_headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kBaseHeaderHeight)] autorelease];
		[_headerView setBackgroundColor:[UIColor colorWithWhite:0.094 alpha:1.0]];
		_headerView.alpha = 0.85;
		
		SNArticleFollowerInfoView_iPhone *articleFollowerView = [[[SNArticleFollowerInfoView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kBaseHeaderHeight) articleVO:_vo] autorelease];
		[_headerView addSubview:articleFollowerView];
		[_holderView addSubview:_headerView];
		
		_expandCollapseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_expandCollapseButton.frame = CGRectMake(240.0, 5.0, 84.0, 34.0);
		[_expandCollapseButton setBackgroundImage:[UIImage imageNamed:@"readMoreButton_nonActive.png"] forState:UIControlStateNormal];
		[_expandCollapseButton setBackgroundImage:[UIImage imageNamed:@"readMoreButton_Active.png"] forState:UIControlStateHighlighted];
		[_expandCollapseButton addTarget:self action:@selector(_goExpandCollapse) forControlEvents:UIControlEventTouchUpInside];
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
			_playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 84.0, 84.0)];
			_playImgView.image = [UIImage imageNamed:@"playIcon.png"];
			
			_playButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			_playButton.frame = CGRectMake(121.0, 165.0, 84.0, 84.0);
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
			[_playButton addTarget:self action:@selector(_goPlayVideo) forControlEvents:UIControlEventTouchUpInside];
			[_playButton addSubview:_playImgView];
			[self addSubview:_playButton];
			
			_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			_indicatorView.frame = CGRectMake(147.0, 191.0, 32.0, 32.0);
			_indicatorView.hidden = YES;
			[_holderView addSubview:_indicatorView];
		}
		
				
		UIView *tweetBgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, _tweetSize.height+ 45.0)] autorelease];
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
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 50.0 + _tweetSize.height, 296.0, _titleSize.height)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:22];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		titleLabel.text = _vo.title;
		titleLabel.numberOfLines = 0;
		[_scrollView addSubview:titleLabel];
		
		UILabel *contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 75.0 + _titleSize.height + _tweetSize.height, 296.0, _contentSize.height)] autorelease];
		contentLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		contentLabel.textColor = [UIColor whiteColor];
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		contentLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		contentLabel.text = _vo.content;
		contentLabel.numberOfLines = 0;
		[_scrollView addSubview:contentLabel];
		
		UIButton *readMoreBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		readMoreBtn.frame = CGRectMake(118.0, 95.0 + _titleSize.height + _tweetSize.height + _contentSize.height, 84.0, 34.0);
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
	}
	
	return (self);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"CHANGE_CARDS" object:nil];
	
	[_headerBgView release];
	[_headerView release];
	
	if (_vo.type_id > 4) {
		[_playImgView release];
		[_indicatorView release];
	}
	
	[super dealloc];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSLog(@"TOUCHED:%@", [touch view]);
	
	if ([touch view] == _bgView) {
		[self _goExpandCollapse];
		return;
	}
}

#pragma mark - Interaction handlers
-(void)resetContent {
	_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - kBaseHeaderHeight, _holderView.frame.size.width, _holderView.frame.size.height);
	_holderView.alpha = 0.0;
	_isExpanded = NO;
	
	[super resetContent];
}

-(void)introContent {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - (kBaseHeaderHeight + _tweetSize.height + 45.0), _holderView.frame.size.width, _holderView.frame.size.height);
		_holderView.alpha = 1.0;
	
	}completion:^(BOOL finished) {
		self.userInteractionEnabled = YES;
	}];
	
	[super introContent];
}

-(void)setTweets:(NSMutableArray *)tweets {
	_tweets = tweets;
}


#pragma mark - Navigation
-(void)_goTag:(UIButton *)button {
	NSLog(@"GO TAG %d", [button tag]);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TAG_SEARCH" object:[NSNumber numberWithInt:[button tag]]];
}

-(void)_goPlayVideo {
	_playImgView.hidden = YES;
	
	[(UIActivityIndicatorView *)_indicatorView startAnimating];
	_indicatorView.hidden = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO" object:_vo];
}

-(void)_goExpandCollapse {
	NSLog(@"_goExpandCollapse");
	
	_isExpanded = !_isExpanded;
	
	if (_isExpanded) {
		[UIView animateWithDuration:0.5 animations:^(void) {
			_holderView.frame = CGRectMake(_holderView.frame.origin.x, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		
		} completion:^(BOOL finished) {
			_scrollView.userInteractionEnabled = YES;
		}];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_playButton.alpha = 0.0;
		}];
	
	} else {
		[UIView animateWithDuration:0.5 animations:^(void) {
			_holderView.frame = CGRectMake(_holderView.frame.origin.x, self.frame.size.height - (kBaseHeaderHeight + _tweetSize.height + 45.0), _holderView.frame.size.width, _holderView.frame.size.height);
		
		} completion:^(BOOL finished) {
			_scrollView.userInteractionEnabled = NO;
			
			[UIView animateWithDuration:0.25 animations:^(void) {
				_playButton.alpha = 1.0;
			}];
		}];
	}
}

-(void)_goReadMore {
	
}


#pragma mark - Notifications
-(void)_videoEnded:(NSNotification *)notification {
	_playImgView.hidden = NO;
	
	[(UIActivityIndicatorView *)_indicatorView stopAnimating];
	_indicatorView.hidden = YES;
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	//int offset = (self.frame.size.height - (kBaseHeaderHeight + _tweetSize.height)) + scrollView.contentOffset.y;
	//NSLog(@"OFFSET:[%f]", scrollView.contentOffset.y);
	
//	if (_playButton != nil) {
//		if (scrollView.contentOffset.y > 160.0)
//			[UIView animateWithDuration:0.25 animations:^(void) {
//				_playButton.alpha = 0.0;
//			}];
//	
//		else
//			[UIView animateWithDuration:0.25 animations:^(void) {
//				_playButton.alpha = 1.0;
//			}];
//	}
//	
//	if (_isAtTop && (scrollView.contentOffset.y < self.frame.size.height - kBaseHeaderHeight)) {
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_BUTTONS" object:nil];
//		_isAtTop = NO;
//		
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			_headerBgView.alpha = 0.85;
//		}];
//	} 
//	
//	if (scrollView.contentOffset.y >= self.frame.size.height - kBaseHeaderHeight) {
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_BUTTONS" object:nil];
//		_isAtTop = YES;
//		
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			_headerBgView.alpha = 1.0;
//		}];
//	}
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
	NSLog(@"IMAGE LOADED:[%@]", imageView.imageURL);
}

-(void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
	NSLog(@"IMAGE LOAD FAIL");
}


@end
