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
#define kBaseHeaderHeight 90.0

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		_tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(300.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_contentSize = [_vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(312.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_bgImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_bgImageView.delegate = self;
		_bgImageView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
		[_holderView addSubview:_bgImageView];
		
		_gridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_gridButton.frame = CGRectMake(12.0, 2.0, 24.0, 24.0);
		
		_shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_shareButton.frame = CGRectMake(272.0, 2.0, 34.0, 34.0);
		
		if (_vo.isDark) {
			[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridIconGray_nonActive.png"] forState:UIControlStateNormal];
			[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridIconGray_Active.png"] forState:UIControlStateHighlighted];
			
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareIconGrey_nonActive.png"] forState:UIControlStateNormal];
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareIconGrey_Active.png"] forState:UIControlStateHighlighted];
		
		} else {
			[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridIcon_nonActive.png"] forState:UIControlStateNormal];
			[_gridButton setBackgroundImage:[UIImage imageNamed:@"gridIcon_Active.png"] forState:UIControlStateHighlighted];
			
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareIcon_nonActive.png"] forState:UIControlStateNormal];
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareIcon_Active.png"] forState:UIControlStateHighlighted];
		}
		
		[_gridButton addTarget:self action:@selector(_goGrid) forControlEvents:UIControlEventTouchUpInside];
		[_shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:_gridButton];
		[self addSubview:_shareButton];
		
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
		_tableView.scrollsToTop = NO;
		_tableView.showsHorizontalScrollIndicator = NO;
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.alwaysBounceVertical = NO;
		[_holderView addSubview:_tableView];
		
		if (_vo.type_id > 4) {
			_playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_playButton.frame = CGRectMake(118.0, 128.0, 84.0, 84.0);
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"tagBG_active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
			[_playButton addTarget:self action:@selector(_goPlayVideo) forControlEvents:UIControlEventTouchUpInside];
			[_holderView addSubview:_playButton];
		}
	}
	
	return (self);
}

-(void)dealloc {
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
-(void)_goGrid {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LEAVE_ARTICLES" object:nil];
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SHEET" object:_vo];
}

-(void)_goTag:(UIButton *)button {
	NSLog(@"GO TAG %d", [button tag]);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TAG_SEARCH" object:[NSNumber numberWithInt:[button tag]]];
}

-(void)_goPlayVideo {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO" object:_vo.video_url];
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
			
			UIView *cellView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, _contentSize.height)] autorelease];
			[cellView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
			[cell addSubview:cellView];
			
			
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
			
			_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 40.0, 312.0, _contentSize.height)];
			_contentLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
			_contentLabel.textColor = [UIColor whiteColor];
			_contentLabel.backgroundColor = [UIColor clearColor];
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
		return (_contentSize.height + 50.0);
	
	else
		return (self.frame.size.height - (_tweetSize.height + kBaseHeaderHeight));
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if (section == 0)
		return (0);
	
	else
		return (_tweetSize.height + kBaseHeaderHeight);
}
			  
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section == 1) {
		UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, _tweetSize.height + kBaseHeaderHeight)] autorelease];
		[headerView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
		
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 72.0, 72.0)];
		_avatarImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[headerView addSubview:_avatarImgView];
		
		_twitterName = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 32.0, 256.0, 20.0)];
		_twitterName.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_twitterName.textColor = [UIColor whiteColor];
		_twitterName.backgroundColor = [UIColor clearColor];
		_twitterName.text = _vo.twitterName;
		[headerView addSubview:_twitterName];
		
		NSString *timeSince = @"";
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			if (days == 1)
				timeSince = @"1 day ago";
			
			else if (days > 1)
				timeSince = [NSString stringWithFormat:@"%d days ago", days];
			
		} else {
			if (hours == 1)
				timeSince = @"1 hour ago";
			
			else if (hours > 1)
				timeSince = [NSString stringWithFormat:@"%d hours ago", hours];
			
			else {
				if (mins == 1)
					timeSince = @"1 minute ago";
				
				else if (mins > 1)
					timeSince = [NSString stringWithFormat:@"%d minutes ago", mins];
			}
		}
		
		_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 32.0, 100.0, 26.0)];
		_dateLabel.textAlignment = UITextAlignmentRight;
		_dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_dateLabel.textColor = [UIColor lightGrayColor];
		_dateLabel.backgroundColor = [UIColor clearColor];
		_dateLabel.text = timeSince;
		_dateLabel.numberOfLines = 0;
		[headerView addSubview:_dateLabel];
		
		_tweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 85.0, 300.0, _tweetSize.height)];
		_tweetLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_tweetLabel.textColor = [UIColor whiteColor];
		_tweetLabel.backgroundColor = [UIColor clearColor];
		_tweetLabel.text = _vo.tweetMessage;
		_tweetLabel.numberOfLines = 0;
		[headerView addSubview:_tweetLabel];
		
		return (headerView);
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
		if (scrollView.contentOffset.y > 20.0)
			_playButton.hidden = YES;
	
		else
			_playButton.hidden = NO;
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


#pragma mark ImageLoader

-(void)imageViewLoadedImage:(EGOImageView *)imageView {
	NSLog(@"IMAGE LOADED:[%@]", imageView.imageURL);
	[self performSelector:@selector(_drawTable) withObject:nil afterDelay:0.125];
}

-(void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
	NSLog(@"IMAGE LOAD FAIL");
}



-(void)_drawTable {
	_scaledImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width - (self.frame.size.width * kImageScale)) * 0.5), ((self.frame.size.height - (self.frame.size.height * kImageScale)) * 0.5), self.frame.size.width * kImageScale, self.frame.size.height * kImageScale)] autorelease];
	_scaledImgView.image = [UIImage imageWithCGImage:[[SNAppDelegate imageWithView:_holderView] CGImage] scale:1.0 orientation:UIImageOrientationUp];
	[self addSubview:_scaledImgView];
	
	_holderView.hidden = YES;
	
	//UIImageView *holderImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width - (self.frame.size.width * kImageScale)) * 0.5), ((self.frame.size.height - (self.frame.size.height * kImageScale)) * 0.5), self.frame.size.width * kImageScale, self.frame.size.height * kImageScale)] autorelease];
	//holderImgView.image = [UIImage imageWithCGImage:[[SNAppDelegate imageWithView:_holderView] CGImage] scale:1.0 orientation:UIImageOrientationUp];
	//[_scaledImgView addSubview:holderImgView];
}

@end
