//
//  SNInfluencerListViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SNInfluencerListViewCell_iPhone.h"

#import "SNAppDelegate.h"


@implementation SNInfluencerListViewCell_iPhone

@synthesize influencerVO = _influencerVO;


+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

-(id)initFromList {
	if ((self = [self init])) {
		_verifiedIcoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(245.0, 14.0, 24.0, 24.0)];
		_verifiedIcoImgView.image = [UIImage imageNamed:@"influencerApprovedIcon.png"];
		[self addSubview:_verifiedIcoImgView];
	}
	
	return (self);
}

-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_avatarImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(21.0, 13.0, 24.0, 24.0)];
		_avatarImgView.layer.cornerRadius = 4.0;
		_avatarImgView.clipsToBounds = YES;
		[self addSubview:_avatarImgView];
		
		_twitterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 16.0, 256.0, 20.0)];
		_twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_twitterNameLabel.textColor = [SNAppDelegate snLinkColor];
		_twitterNameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_twitterNameLabel];
		
		_verifiedIcoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 40.0, 14.0, 24.0, 24.0)];
		_verifiedIcoImgView.image = [UIImage imageNamed:@"influencerApprovedIcon.png"];
		[self addSubview:_verifiedIcoImgView];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 50.0, self.frame.size.width - 20.0, 1.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}


#pragma mark - Accessors
- (void)setInfluencerVO:(SNInfluencerVO *)influencerVO {
	_influencerVO = influencerVO;
	
	_avatarImgView.imageURL = [NSURL URLWithString:_influencerVO.avatar_url];
	_twitterNameLabel.text = [NSString stringWithFormat:@"@%@", _influencerVO.handle];
	_verifiedIcoImgView.hidden = !_influencerVO.isApproved;
}

@end
