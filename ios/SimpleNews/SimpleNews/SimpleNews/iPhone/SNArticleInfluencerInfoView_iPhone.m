//
//  SNArticleInfluencerInfoView_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.23.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNArticleInfluencerInfoView_iPhone.h"

#import "SNAppDelegate.h"
#import "EGOImageView.h"

@implementation SNArticleInfluencerInfoView_iPhone

-(id)initWithFrame:(CGRect)frame articleVO:(SNArticleVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_vo = vo;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -20.0, 320.0, 101.0)];
		bgImgView.image = [UIImage imageNamed:@"topOfStoryBackground.png"];
		[self addSubview:bgImgView];
		
		EGOImageView *avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 6.0, 50.0, 50.0)];
		avatarImgView.layer.cornerRadius = 8.0;
		avatarImgView.clipsToBounds = YES;
		avatarImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		avatarImgView.layer.borderWidth = 1.0;
		avatarImgView.imageURL = [NSURL URLWithString:_vo.avatarImage_url];
		[self addSubview:avatarImgView];
		
		UIImageView *twitterIcoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(72.0, 9.0, 14.0, 14.0)];
		twitterIcoImgView.image = [UIImage imageNamed:@"twitterIconGray.png"];
		[self addSubview:twitterIcoImgView];
		
		UILabel *twitterName = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 8.0, 256.0, 20.0)];
		twitterName.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		twitterName.textColor = [UIColor colorWithWhite:0.325 alpha:1.0];
		twitterName.backgroundColor = [UIColor clearColor];
		twitterName.text = _vo.twitterName;
		[self addSubview:twitterName];
		
		UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0, 27.0, 210.0, 30.0)];
		infoLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		infoLabel.textColor = [UIColor blackColor];
		infoLabel.backgroundColor = [UIColor clearColor];
		infoLabel.text = _vo.tweetMessage;
		infoLabel.numberOfLines = 2;
		[self addSubview:infoLabel];
		
		UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		twitterButton.frame = CGRectMake(0.0, 0.0, 280.0, self.frame.size.height);
		//[twitterButton addTarget:self action:@selector(_goTwitterPage) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:twitterButton];
	}
	
	return (self);
}

-(void)dealloc {
}


#pragma mark - Navigation
-(void)_goTwitterPage {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:[NSString stringWithFormat:@"https://twitter.com/#!/%@/", _vo.twitterHandle]];
}

@end
