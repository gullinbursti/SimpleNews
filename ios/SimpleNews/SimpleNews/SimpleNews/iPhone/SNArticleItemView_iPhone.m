//
//  SNArticleItemView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleItemView_iPhone.h"
#import "SNAppDelegate.h"

#import "EGOImageView.h"

@implementation SNArticleItemView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		EGOImageView *thumbImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 35.0, 35.0)] autorelease];
		thumbImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[self addSubview:thumbImgView];
		
		UILabel *twitterName = [[[UILabel alloc] initWithFrame:CGRectMake(56.0, 21.0, 256.0, 20.0)] autorelease];
		twitterName.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		twitterName.textColor = [UIColor blackColor];
		twitterName.backgroundColor = [UIColor clearColor];
		twitterName.text = _vo.twitterName;
		[self addSubview:twitterName];
		
		CGSize tweetSize = [_vo.tweetMessage sizeWithFont:[[SNAppDelegate snAllerFontRegular] fontWithSize:14] constrainedToSize:CGSizeMake(252.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		UILabel *tweetLabel = [[[UILabel alloc] initWithFrame:CGRectMake(56.0, 46.0, 252.0, tweetSize.height)] autorelease];
		tweetLabel.font = [[SNAppDelegate snAllerFontRegular] fontWithSize:14];
		tweetLabel.textColor = [UIColor colorWithWhite:0.482 alpha:1.0];
		tweetLabel.backgroundColor = [UIColor clearColor];
		tweetLabel.text = _vo.tweetMessage;
		tweetLabel.numberOfLines = 0;
		[self addSubview:tweetLabel];
		
		UIView *headerLineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 200.0, self.frame.size.width, 1.0)] autorelease];
		[headerLineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:headerLineView];
	}
	
	return (self);
}

-(void)dealloc {
	
}

@end
