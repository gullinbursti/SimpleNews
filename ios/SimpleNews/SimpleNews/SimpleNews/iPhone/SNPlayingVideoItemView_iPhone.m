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
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 180.0, self.frame.size.width, self.frame.size.height - 180.0)];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.delegate = self;
		_scrollView.opaque = NO;
		_scrollView.contentSize = CGSizeMake(self.frame.size.width , self.frame.size.height - 180.0);
		_scrollView.scrollsToTop = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = NO;
		[self addSubview:_scrollView];
		
		_imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0.0, -22.0, self.frame.size.width, 230.0)];
		_imageView.imageURL = [NSURL URLWithString:_vo.image_url];
		[self addSubview:_imageView];
		
		_channelImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(27.0, 20.0, 44.0, 44.0)];
		_channelImageView.imageURL = [NSURL URLWithString:_vo.image_url];
		[_scrollView addSubview:_channelImageView];
		
		_titleSize = [_vo.video_title sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18] constrainedToSize:CGSizeMake(self.frame.size.width - 35.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 60.0, _titleSize.width, _titleSize.height)];
		_titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:18.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.numberOfLines = 0;
		_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = _vo.video_title;
		[_scrollView addSubview:_titleLabel];
		
		_infoSize = [_vo.video_info sizeWithFont:[[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:14] constrainedToSize:CGSizeMake(self.frame.size.width - 35.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 80.0 + _titleSize.height, _infoSize.width, _infoSize.height)];
		_infoLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:14.0];
		_infoLabel.backgroundColor = [UIColor clearColor];
		_infoLabel.textColor = [UIColor grayColor];
		_infoLabel.numberOfLines = 0;
		_infoLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_infoLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_infoLabel.text = _vo.video_info;
		[_scrollView addSubview:_infoLabel];
		
		
		_scrollView.contentSize = CGSizeMake(self.frame.size.width , 80.0 + (_titleSize.height + _infoSize.height));
	}
	
	return (self);
}


-(void)fadeInImage {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_imageView.alpha = 1.0;
	}];
}

-(void)fadeOutImage {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_imageView.alpha = 0.0;
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
