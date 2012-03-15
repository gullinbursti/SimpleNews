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

@synthesize scaledImgView = _scaledImgView;
@synthesize holderView = _holderView;

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		_holderView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:_holderView];
		
		_bgImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_bgImageView.delegate = self;
		_bgImageView.imageURL = [NSURL URLWithString:_vo.bgImage_url];
		[_holderView addSubview:_bgImageView];
		
		_shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_shareButton.frame = CGRectMake(272.0, 2.0, 44.0, 44.0);
		
		if (_vo.isDark) {
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActiveWhite.png"] forState:UIControlStateNormal];
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_activeWhite.png"] forState:UIControlStateHighlighted];
		
		} else {
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive.png"] forState:UIControlStateNormal];
			[_shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_active.png"] forState:UIControlStateHighlighted];
		}
		
		[_shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
		[_holderView addSubview:_shareButton];
		
		CGSize tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(300.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_contentBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - (100.0 + tweetSize.height), self.frame.size.width, (120.0 + tweetSize.height))];
		[_contentBGView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		[_holderView addSubview:_contentBGView];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - (100.0 + tweetSize.height), self.frame.size.height, (100.0 + tweetSize.height))];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.opaque = YES;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = YES;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
		[_holderView addSubview:_scrollView];
		
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(4.0, 4.0, 72.0, 72.0)];
		_avatarImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[_scrollView addSubview:_avatarImgView];
		
		_twitterName = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 32.0, 256.0, 20.0)];
		_twitterName.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_twitterName.textColor = [UIColor whiteColor];
		_twitterName.backgroundColor = [UIColor clearColor];
		_twitterName.text = _vo.twitterName;
		[_scrollView addSubview:_twitterName];
		
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
		[_scrollView addSubview:_dateLabel];
		
		_tweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 85.0, 300.0, tweetSize.height)];
		_tweetLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:16];
		_tweetLabel.textColor = [UIColor whiteColor];
		_tweetLabel.backgroundColor = [UIColor clearColor];
		_tweetLabel.text = _vo.tweetMessage;
		_tweetLabel.numberOfLines = 0;
		[_scrollView addSubview:_tweetLabel];
		
		float width = 0;
		
		for (SNTagVO *tagVO in _vo.tags) {
			CGSize tagSize = [[NSString stringWithFormat:@"   #%@   ", tagVO.title] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10.0] constrainedToSize:CGSizeMake(160.0, 24.0) lineBreakMode:UILineBreakModeClip]; 
			
			UIButton *tagButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			tagButton.frame = CGRectMake(width, 95.0 + tweetSize.height, tagSize.width, 24.0);
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
			[_scrollView addSubview:tagButton];
			
			width += (tagSize.width + 8.0);
		}
		
		_scrollView.contentSize = CGSizeMake(self.frame.size.width, (120.0 + tweetSize.height));
		
		if (_vo.type_id > 4) {
			
			_playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_playButton.frame = CGRectMake(128.0, 128.0, 64.0, 64.0);
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"playButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
			[_playButton setBackgroundImage:[[UIImage imageNamed:@"tagBG_active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
			[_playButton addTarget:self action:@selector(_goPlayVideo) forControlEvents:UIControlEventTouchUpInside];
			[_holderView addSubview:_playButton];
		}
	}
	
	return (self);
}

-(void)dealloc {
	[_contentBGView release];
	[_scrollView release];
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
-(void)_goShare {
	
}

-(void)_goTag:(UIButton *)button {
	NSLog(@"GO TAG %d", [button tag]);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TAG_SEARCH" object:nil];
}

-(void)_goPlayVideo {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO" object:_vo.video_url];
}



#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_contentBGView.frame = CGRectMake(0.0, 300.0 - scrollView.contentOffset.y, _contentBGView.frame.size.width, _contentBGView.frame.size.height);
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
	
	_scaledImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width - (self.frame.size.width * kImageScale)) * 0.5), ((self.frame.size.height - (self.frame.size.height * kImageScale)) * 0.5), self.frame.size.width * kImageScale, self.frame.size.height * kImageScale)] autorelease];
	_scaledImgView.image = [UIImage imageWithCGImage:[[SNAppDelegate imageWithView:_bgImageView] CGImage] scale:1.0 orientation:UIImageOrientationUp];
	[self addSubview:_scaledImgView];
	
	_holderView.hidden = YES;
}

-(void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
	NSLog(@"IMAGE LOAD FAIL");
}


@end
