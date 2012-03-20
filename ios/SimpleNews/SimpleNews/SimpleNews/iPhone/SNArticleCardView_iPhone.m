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

@implementation SNArticleCardView_iPhone

#define kImageScale 0.9
#define kBaseHeaderHeight 65.0

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeCards:) name:@"CHANGE_CARDS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		_vo = vo;
		_isAtTop = NO;
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		_tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_titleSize = [_vo.title sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:22] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_contentSize = [_vo.content sizeWithFont:[[SNAppDelegate snAllerFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(296.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_holderView.frame = CGRectMake(_holderView.frame.origin.x, _holderView.frame.origin.y, self.frame.size.width, self.frame.size.height + _contentSize.height + _titleSize.height);
		
		_bgImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_bgImageView.delegate = self;
		_bgImageView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
		[_holderView addSubview:_bgImageView];
		
		NSLog(@"CONTENT HEIGHT:[%f]", _contentSize.height);
		
		_tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.rowHeight = _contentSize.height;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.allowsSelection = NO;
		_tableView.pagingEnabled = NO;
		_tableView.opaque = NO;
		_tableView.scrollsToTop = YES;
		_tableView.showsHorizontalScrollIndicator = NO;
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.alwaysBounceVertical = NO;
		[_holderView addSubview:_tableView];
		
		if (_vo.type_id > 4) {
			_playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(25.0, 25.0, 34.0, 34.0)];
			_playImgView.image = [UIImage imageNamed:@"playIcon.png"];
			
			_playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_playButton.frame = CGRectMake(121.0, 165.0, 84.0, 84.0);
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
			[_playButton addTarget:self action:@selector(_goPlayVideo) forControlEvents:UIControlEventTouchUpInside];
			[_playButton addSubview:_playImgView];
			[_holderView addSubview:_playButton];
			
			_indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
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
	[_avatarImgView release];
	[_tweetLabel release];
	[_twitterName release];
	[_playButton release];
	
	[super dealloc];
}

-(void)setScaledImgView:(UIImageView *)scaledImgView {
	_scaledImgView = scaledImgView;
	[self addSubview:_scaledImgView];
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


#pragma mark - Notifications
-(void)_changeCards:(NSNotification *)notification {
	[self performSelector:@selector(_resetMe) withObject:nil afterDelay:0.33];
}

-(void)_videoEnded:(NSNotification *)notification {
	_playImgView.hidden = NO;
	
	[(UIActivityIndicatorView *)_indicatorView stopAnimating];
	_indicatorView.hidden = YES;
}


#pragma mark - Interaction handlers
-(void)_resetMe {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tableView.contentOffset = CGPointMake(0.0, 45.0 + _tweetSize.height);
	}];
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
			
			//cell. = NO;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell setUserInteractionEnabled:NO];
			
			UIView *cellView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, _contentSize.height + _titleSize.height + 52.0)] autorelease];
			[cellView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
			[cell addSubview:cellView];
			
			_tweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 296.0, _tweetSize.height)];
			_tweetLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
			_tweetLabel.textColor = [UIColor whiteColor];
			_tweetLabel.backgroundColor = [UIColor clearColor];
			_tweetLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			_tweetLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			_tweetLabel.text = _vo.tweetMessage;
			_tweetLabel.numberOfLines = 0;
			[cell addSubview:_tweetLabel];
			
			UIImageView *twitterIcoImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(12.0, 20.0 + _tweetSize.height, 14.0, 14.0)] autorelease];
			twitterIcoImgView.image = [UIImage imageNamed:@"twitterIcon.png"];
			[cell addSubview:twitterIcoImgView];
			
			UILabel *twitterSiteLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30.0, 20.0 + _tweetSize.height, 150.0, 16.0)] autorelease];
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
			
			_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 50.0 + _tweetSize.height, 296.0, _titleSize.height)];
			_titleLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:22];
			_titleLabel.textColor = [UIColor whiteColor];
			_titleLabel.backgroundColor = [UIColor clearColor];
			_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			_titleLabel.text = _vo.title;
			_titleLabel.numberOfLines = 0;
			[cell addSubview:_titleLabel];
			
			_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 75.0 + _titleSize.height + _tweetSize.height, 296.0, _contentSize.height)];
			_contentLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
			_contentLabel.textColor = [UIColor whiteColor];
			_contentLabel.backgroundColor = [UIColor clearColor];
			_contentLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			_contentLabel.shadowOffset = CGSizeMake(1.0, 1.0);
			_contentLabel.text = _vo.content;
			_contentLabel.numberOfLines = 0;
			[cell addSubview:_contentLabel];
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
		return (_contentSize.height + 160.0);
	
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
		[_headerView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 40.0, 40.0)];
		_avatarImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[_headerView addSubview:_avatarImgView];
		
		_twitterName = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 20.0, 256.0, 20.0)];
		_twitterName.font = [[SNAppDelegate snAllerFontBold] fontWithSize:16];
		_twitterName.textColor = [UIColor whiteColor];
		_twitterName.backgroundColor = [UIColor clearColor];
		_twitterName.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_twitterName.shadowOffset = CGSizeMake(1.0, 1.0);
		_twitterName.text = _vo.twitterName;
		[_headerView addSubview:_twitterName];
		
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
		
		_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(269.0, 20.0, 41.0, 26.0)];
		_dateLabel.textAlignment = UITextAlignmentRight;
		_dateLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12];
		_dateLabel.textColor = [UIColor lightGrayColor];
		_dateLabel.backgroundColor = [UIColor clearColor];
		_dateLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_dateLabel.text = timeSince;
		_dateLabel.numberOfLines = 0;
		[_headerView addSubview:_dateLabel];
		
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


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}



#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	//int offset = (self.frame.size.height - (kBaseHeaderHeight + _tweetSize.height)) + scrollView.contentOffset.y;
	NSLog(@"OFFSET:[%f]", scrollView.contentOffset.y);
	
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
		
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			[_headerView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
//		}];
		
		[_headerView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
	} 
	
	if (scrollView.contentOffset.y >= self.frame.size.height - kBaseHeaderHeight) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_BUTTONS" object:nil];
		_isAtTop = YES;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			[_headerView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
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


#pragma mark - ImageLoader

-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	NSLog(@"IMAGE LOADED:[%@]", imageView.imageURL);
	[self performSelector:@selector(_drawTable) withObject:nil afterDelay:0.125];
}

-(void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
	NSLog(@"IMAGE LOAD FAIL");
}



-(void)_drawTable {
	_scaledImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width - (self.frame.size.width * kImageScale)) * 0.5), ((self.frame.size.height - (self.frame.size.height * kImageScale)) * 0.5), self.frame.size.width * kImageScale, self.frame.size.height * kImageScale)] autorelease];
	_scaledImgView.image = [UIImage imageWithCGImage:[[SNAppDelegate imageWithView:self] CGImage] scale:1.0 orientation:UIImageOrientationUp];
	[self addSubview:_scaledImgView];
	
	_holderView.hidden = YES;
	//[self hideButtons];
	
	//UIImageView *holderImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width - (self.frame.size.width * kImageScale)) * 0.5), ((self.frame.size.height - (self.frame.size.height * kImageScale)) * 0.5), self.frame.size.width * kImageScale, self.frame.size.height * kImageScale)] autorelease];
	//holderImgView.image = [UIImage imageWithCGImage:[[SNAppDelegate imageWithView:_holderView] CGImage] scale:1.0 orientation:UIImageOrientationUp];
	//[_scaledImgView addSubview:holderImgView];
	
	//self.alpha = 0.0;
	
	[self _resetMe];
}

@end
