//
//  SNPlayingVideoItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNPlayingVideoItemView_iPhone.h"

#import "SNAppDelegate.h"

@implementation SNPlayingVideoItemView_iPhone

-(id)initWithFrame:(CGRect)frame withVO:(SNVideoItemVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height - 0.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.delegate = self;
		_scrollView.opaque = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width , self.frame.size.height - 180.0);
		_scrollView.scrollsToTop = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		[self addSubview:_scrollView];
		
		UIView *imgHolder = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 180.0)] autorelease];
		imgHolder.clipsToBounds = YES;
		[_scrollView addSubview:imgHolder];
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, -29.0, self.frame.size.width, 240.0)];
		_imageView.imageURL = [NSURL URLWithString:_vo.image_url];
		[imgHolder addSubview:_imageView];
		
		_channelImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 197.0, 44.0, 44.0)];
		_channelImageView.imageURL = [NSURL URLWithString:_vo.channelImg_url];
		[_scrollView addSubview:_channelImageView];
		
		
		//int mins = [SNAppDelegate minutesAfterDate:_vo.postedDate];
		//int hours = [SNAppDelegate hoursAfterDate:[NSDate dateWithTimeIntervalSince1970:0]];
		//int days = [SNAppDelegate daysAfterDate:_vo.postedDate];
		
		//NSLog(@"DATE:[%@] (%d, %d)", _vo.postedDate, days, hours);
		NSLog(@"DATE:[%@]", _vo.postedDate);
		
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		
		/*
		if (days > 0) {
			if (days == 1)
				_dateLabel.text = @"1 day ago";
			
			else if (days > 1)
				_dateLabel.text = [NSString stringWithFormat:@"%d days ago", days];
			
		} else {
			if (hours == 1)
				_dateLabel.text = @"1 hour ago";
			
			else if (hours > 1)
				_dateLabel.text = [NSString stringWithFormat:@"%d hours ago", hours];
		}
		*/
		
		_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 210.0, 200.0, 18.0)];
		_dateLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:14.0];
		_dateLabel.backgroundColor = [UIColor clearColor];
		_dateLabel.textColor = [UIColor grayColor];
		_dateLabel.numberOfLines = 0;
		_dateLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		//_dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:_vo.postedDate]];
		_dateLabel.text = _vo.posted;
		[_scrollView addSubview:_dateLabel];

		
		_titleSize = [_vo.video_title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18] constrainedToSize:CGSizeMake(self.frame.size.width - 35.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 255.0, _titleSize.width, _titleSize.height)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.numberOfLines = 0;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = _vo.video_title;
		[_scrollView addSubview:_titleLabel];
		
		_infoSize = [_vo.video_info sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:14] constrainedToSize:CGSizeMake(self.frame.size.width - 35.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 270.0 + _titleSize.height, _infoSize.width, _infoSize.height)];
		_infoLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:14.0];
		_infoLabel.backgroundColor = [UIColor clearColor];
		_infoLabel.textColor = [UIColor grayColor];
		_infoLabel.numberOfLines = 0;
		_infoLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_infoLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_infoLabel.text = _vo.video_info;
		[_scrollView addSubview:_infoLabel];
				
		_scrollView.contentSize = CGSizeMake(self.frame.size.width , 320.0 + (_titleSize.height + _infoSize.height));
	}
	
	return (self);
}


-(void)fadeInImage {
	_imageView.hidden = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_imageView.alpha = 1.0;
	}];
}

-(void)fadeOutImage {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_imageView.alpha = 0.0;
	
	} completion:^(BOOL finished) {
		_imageView.hidden = YES;
	}];
}

-(void)resetScroll {
	[UIView animateWithDuration:0.25 delay:0.33 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		_scrollView.contentOffset = CGPointMake(0.0, 0.0);
	} completion:nil];
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_DETAILS_SCROLL" object:[NSNumber numberWithFloat:scrollView.contentOffset.y]];
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

@end
