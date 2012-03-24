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
		
		self.userInteractionEnabled = NO;
		[self setBackgroundColor:[UIColor clearColor]];
		
		_tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_titleSize = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:22] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_contentSize = [_vo.content sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_holderView.frame = CGRectMake(_holderView.frame.origin.x, _holderView.frame.origin.y, self.frame.size.width, self.frame.size.height + _contentSize.height + _titleSize.height);
		//_scaledImgView = [[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width - (self.frame.size.width * kImageScale)) * 0.5), ((self.frame.size.height - (self.frame.size.height * kImageScale)) * 0.5), self.frame.size.width * kImageScale, self.frame.size.height * kImageScale)];
		//[_scaledImgView setBackgroundColor:[UIColor redColor]];
		
		EGOImageView *bgImageView = [[[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
		bgImageView.delegate = self;
		bgImageView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
		[_bgView addSubview:bgImageView];
						
		//NSLog(@"CONTENT HEIGHT:[%f]", _contentSize.height);
		_tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		_tableView.alpha = 0.0;
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.rowHeight = _contentSize.height;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.allowsSelection = NO;
		_tableView.pagingEnabled = NO;
		_tableView.opaque = NO;
		_tableView.scrollsToTop = YES;
		_tableView.contentOffset = CGPointMake(0.0, _tweetSize.height);
		_tableView.showsHorizontalScrollIndicator = NO;
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.alwaysBounceVertical = NO;
		[_holderView addSubview:_tableView];
		
		if (_vo.type_id > 4) {
			_playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 84.0, 84.0)];
			_playImgView.image = [UIImage imageNamed:@"playIcon.png"];
			
			_playButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			_playButton.frame = CGRectMake(121.0, 165.0, 84.0, 84.0);
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
			[_playButton addTarget:self action:@selector(_goPlayVideo) forControlEvents:UIControlEventTouchUpInside];
			[_playButton addSubview:_playImgView];
			[_holderView addSubview:_playButton];
			
			_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			_indicatorView.frame = CGRectMake(147.0, 191.0, 32.0, 32.0);
			_indicatorView.hidden = YES;
			[_holderView addSubview:_indicatorView];
		}
	}
	
	return (self);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"CHANGE_CARDS" object:nil];
	
	[_tableView release];
	[_headerBgView release];
	[_headerView release];
	
	if (_vo.type_id > 4) {
		[_playImgView release];
		[_indicatorView release];
	}
	
	[super dealloc];
}


#pragma mark - Interaction handlers
-(void)resetContent {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	self.userInteractionEnabled = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tableView.contentOffset = CGPointMake(0.0, _tweetSize.height);
	
	} completion:^(BOOL finished){
		_tableView.alpha = 0.0;
	}];
	
	[super resetContent];
}

-(void)introContent {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tableView.contentOffset = CGPointMake(0.0, 45.0 + _tweetSize.height);
		_tableView.alpha = 1.0;
	
	} completion:^(BOOL finished) {
		self.userInteractionEnabled = YES;
	}];
	
	[super introContent];
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

-(void)_goReadMore {
	
}


#pragma mark - Notifications
-(void)_videoEnded:(NSNotification *)notification {
	_playImgView.hidden = NO;
	
	[(UIActivityIndicatorView *)_indicatorView stopAnimating];
	_indicatorView.hidden = YES;
}


#pragma mark - TableView Data Source Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 1) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell setUserInteractionEnabled:NO];
			
			UIView *cellView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, _tweetSize.height + _contentSize.height + _titleSize.height + 250.0)] autorelease];
			[cellView setBackgroundColor:[UIColor colorWithWhite:0.137 alpha:1.0]];
			[cell addSubview:cellView];
			
			UIView *tweetBgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _tableView.frame.size.width, _tweetSize.height+ 45.0)] autorelease];
			[tweetBgView setBackgroundColor:[UIColor colorWithWhite:0.184 alpha:1.0]];
			[cell addSubview:tweetBgView];
			
			UILabel *tweetLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 12.0, 296.0, _tweetSize.height)] autorelease];
			tweetLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
			tweetLabel.textColor = [UIColor whiteColor];
			tweetLabel.backgroundColor = [UIColor clearColor];
			tweetLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			tweetLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			tweetLabel.text = _vo.tweetMessage;
			tweetLabel.numberOfLines = 0;
			[cell addSubview:tweetLabel];
			
			UIImageView *twitterIcoImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(12.0, 17.0 + _tweetSize.height, 14.0, 14.0)] autorelease];
			twitterIcoImgView.image = [UIImage imageNamed:@"twitterIcon.png"];
			[cell addSubview:twitterIcoImgView];
			
			UILabel *twitterSiteLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30.0, 17.0 + _tweetSize.height, 150.0, 16.0)] autorelease];
			twitterSiteLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12];
			twitterSiteLabel.textColor = [UIColor whiteColor];
			twitterSiteLabel.backgroundColor = [UIColor clearColor];
			twitterSiteLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			twitterSiteLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			twitterSiteLabel.text = @"Twitter.com";
			[cell addSubview:twitterSiteLabel];
			
			
			/*
			float width = 0;
			for (SNTagVO *tagVO in _vo.tags) {
				CGSize tagSize = [[NSString stringWithFormat:@"   #%@   ", tagVO.title] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10.0] constrainedToSize:CGSizeMake(160.0, 24.0) lineBreakMode:UILineBreakModeClip]; 
				
				UIButton *tagButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
				tagButton.frame = CGRectMake(width, 0.0, tagSize.width, 24.0);
				[tagButton setBackgroundImage:[[UIImage imageNamed:@"tagBG_nonActive.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:12.0] forState:UIControlStateNormal];
				[tagButton setBackgroundImage:[[UIImage imageNamed:@"tagBG_active.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:12.0] forState:UIControlStateHighlighted];
				tagButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10.0];
				tagButton.titleLabel.textAlignment = UITextAlignmentCenter;
				[tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				tagButton.titleLabel.shadowColor = [UIColor blackColor];
				tagButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
				[tagButton setTitle:[NSString stringWithFormat:@"#%@", tagVO.title] forState:UIControlStateNormal];
				[tagButton addTarget:self action:@selector(_goTag:) forControlEvents:UIControlEventTouchUpInside];
				[tagButton setTag:tagVO.tag_id];
				[cell addSubview:tagButton];
				
				width += (tagSize.width + 8.0);
			}
			*/
			
			UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 50.0 + _tweetSize.height, 296.0, _titleSize.height)] autorelease];
			titleLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:22];
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			titleLabel.text = _vo.title;
			titleLabel.numberOfLines = 0;
			[cell addSubview:titleLabel];
			
			UILabel *contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 75.0 + _titleSize.height + _tweetSize.height, 296.0, _contentSize.height)] autorelease];
			contentLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
			contentLabel.textColor = [UIColor whiteColor];
			contentLabel.backgroundColor = [UIColor clearColor];
			contentLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			contentLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			contentLabel.text = _vo.content;
			contentLabel.numberOfLines = 0;
			[cell addSubview:contentLabel];
			
			UIButton *_readMoreBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_readMoreBtn.frame = CGRectMake(118.0, 95.0 + _titleSize.height + _tweetSize.height + _contentSize.height, 84.0, 34.0);
			[_readMoreBtn setBackgroundImage:[UIImage imageNamed:@"readMoreButton_nonActive.png"] forState:UIControlStateNormal];
			[_readMoreBtn setBackgroundImage:[UIImage imageNamed:@"readMoreButton_Active.png"] forState:UIControlStateHighlighted];
			_readMoreBtn.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:13.0];
			_readMoreBtn.titleLabel.textAlignment = UITextAlignmentCenter;
			[_readMoreBtn setTitleColor:[UIColor colorWithWhite:0.773 alpha:1.0] forState:UIControlStateNormal];
			_readMoreBtn.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			_readMoreBtn.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			[_readMoreBtn setTitle:@"Read More" forState:UIControlStateNormal];

			[_readMoreBtn addTarget:self action:@selector(_goReadMore) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:_readMoreBtn];
		}
		
		return (cell);
	
	} else {
		UITableViewCell *cell = nil;
		cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
		
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell setUserInteractionEnabled:NO];
		}
		
		return (cell);
	}
}

#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 1)
		return (_titleSize.height + _contentSize.height + _tweetSize.height + 150.0);
	
	else
		return (self.frame.size.height - kBaseHeaderHeight);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if (section == 0)
		return (0);
	
	else
		return (kBaseHeaderHeight);
}
			  
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section == 1) {
		_headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, kBaseHeaderHeight)] autorelease];
		
		_headerBgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, kBaseHeaderHeight)] autorelease];
		[_headerBgView setBackgroundColor:[UIColor colorWithWhite:0.094 alpha:1.0]];
		_headerBgView.alpha = 0.85;
		[_headerView addSubview:_headerBgView];
		
		SNArticleFollowerInfoView_iPhone *articleFollowerView = [[[SNArticleFollowerInfoView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kBaseHeaderHeight) articleVO:_vo] autorelease];
		[_headerView addSubview:articleFollowerView];
		
		return (_headerView);
	}
	
	return (nil);
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	return (nil);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	//int offset = (self.frame.size.height - (kBaseHeaderHeight + _tweetSize.height)) + scrollView.contentOffset.y;
	//NSLog(@"OFFSET:[%f]", scrollView.contentOffset.y);
	
	if (_playButton != nil) {
		if (scrollView.contentOffset.y > 160.0)
			[UIView animateWithDuration:0.25 animations:^(void) {
				_playButton.alpha = 0.0;
			}];
	
		else
			[UIView animateWithDuration:0.25 animations:^(void) {
				_playButton.alpha = 1.0;
			}];
	}
	
	if (_isAtTop && (scrollView.contentOffset.y < self.frame.size.height - kBaseHeaderHeight)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_BUTTONS" object:nil];
		_isAtTop = NO;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_headerBgView.alpha = 0.85;
		}];
	} 
	
	if (scrollView.contentOffset.y >= self.frame.size.height - kBaseHeaderHeight) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_BUTTONS" object:nil];
		_isAtTop = YES;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_headerBgView.alpha = 1.0;
		}];
	}
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
