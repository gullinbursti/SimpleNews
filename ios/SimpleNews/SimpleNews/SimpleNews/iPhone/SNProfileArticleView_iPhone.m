//
//  SNProfileArticleView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.26.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileArticleView_iPhone.h"
#import "SNAppDelegate.h"
#import "EGOImageView.h"

@implementation SNProfileArticleView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		EGOImageView *thumbImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 75.0, 75.0)] autorelease];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.thumb_url];
		[self addSubview:thumbImgView];
		
		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100.0, 24.0, 212.0, 40)] autorelease];
		titleLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:16];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		titleLabel.text = _vo.title;
		titleLabel.numberOfLines = 0;
		[self addSubview:titleLabel];
		
		NSString *timeSince = @"";
		int mins = [SNAppDelegate minutesAfterDate:_vo.added];
		int hours = [SNAppDelegate hoursAfterDate:_vo.added];
		int days = [SNAppDelegate daysAfterDate:_vo.added];
		
		if (days > 0) {
			timeSince = [NSString stringWithFormat:@"%dd ago", days];
			
		} else {
			if (hours > 0)
				timeSince = [NSString stringWithFormat:@"%dh ago", hours];
			
			else
				timeSince = [NSString stringWithFormat:@"%dm ago", mins];
		}
		
		UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100.0, 72.0, 41.0, 16.0)] autorelease];
		dateLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
		dateLabel.textColor = [UIColor colorWithWhite:0.329 alpha:1.0];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		dateLabel.text = timeSince;
		dateLabel.numberOfLines = 0;
		[self addSubview:dateLabel];
	}
	
	return (self);
}

-(void)dealloc {
	[super dealloc];
}

@end
