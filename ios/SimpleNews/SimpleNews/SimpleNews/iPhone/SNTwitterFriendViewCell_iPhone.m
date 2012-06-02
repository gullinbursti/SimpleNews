//
//  SNTwitterFriendViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.22.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTwitterFriendViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNTwitterAvatarView.h"

@implementation SNTwitterFriendViewCell_iPhone

@synthesize twitterUserVO = _twitterUserVO;

+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)initAsHeader {
	if ((self = [self init])) {
		[_bgImgView setBackgroundColor:[SNAppDelegate snDebugBlueColor]];
		_bgImgView.image = [UIImage imageNamed:@"profileBackground.png"];
	}
	
	return (self);
}

- (id)initAsMiddle {
	if ((self = [self init])) {
		[_bgImgView setBackgroundColor:[SNAppDelegate snDebugGreenColor]];
		_bgImgView.image = [UIImage imageNamed:@"profileBackground.png"];
	}
	
	return (self);
}

- (id)initAsFooter {
	if ((self = [self init])) {
		[_bgImgView setBackgroundColor:[SNAppDelegate snDebugRedColor]];
		_bgImgView.image = [UIImage imageNamed:@"profileBackground.png"];
	}
	
	return (self);
}



-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width - 40.0, 70.0)];
		[self addSubview:_bgImgView];
		
		_handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 27.0, 200.0, 16.0)];
		_handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_handleLabel.textColor = [SNAppDelegate snLinkColor];
		_handleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_handleLabel];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 32.0, 200.0, 16.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_nameLabel.textColor = [SNAppDelegate snLinkColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		
		UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 70.0, self.frame.size.width - 40.0, 2.0)];
		UIImage *img = [UIImage imageNamed:@"line.png"];
		lineImgView.image = [img stretchableImageWithLeftCapWidth:2.0 topCapHeight:0.0];
		[self addSubview:lineImgView];
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)setTwitterUserVO:(SNTwitterUserVO *)twitterUserVO {
	_twitterUserVO = twitterUserVO;
	
	SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(20.0, 19.0) imageURL:twitterUserVO.avatarURL];
	[self addSubview:avatarImgView];
	
	_handleLabel.text = [NSString stringWithFormat:@"@%@", _twitterUserVO.handle];
}

@end
