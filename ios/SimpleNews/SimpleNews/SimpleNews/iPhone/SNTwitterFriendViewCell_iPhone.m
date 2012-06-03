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
		UIImage *img = [UIImage imageNamed:@"topBackground.png"];
		_bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:7.0];
	}
	
	return (self);
}

- (id)initAsMiddle {
	if ((self = [self init])) {
		UIImage *img = [UIImage imageNamed:@"midBackground.png"];
		_bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:7.0];
	}
	
	return (self);
}

- (id)initAsFooter {
	if ((self = [self init])) {
		UIImage *img = [UIImage imageNamed:@"botBackground.png"];
		_bgImgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:7.0];		
		[_lineView removeFromSuperview];
	}
	
	return (self);
}



-(id)init {
	//if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
	if ((self = [super init])) { //WithStyle:UITableViewCellStyleDefault reuseIdentifier:nil])) {
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width - 20.0, 56.0)];
		[self addSubview:_bgImgView];
		
		_handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 23.0, 200.0, 16.0)];
		_handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_handleLabel.textColor = [SNAppDelegate snLinkColor];
		_handleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_handleLabel];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 32.0, 200.0, 16.0)];
		_nameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		_nameLabel.textColor = [SNAppDelegate snLinkColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		
		_lineView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 56.0, self.frame.size.width - 43.0, 1.0)];
		[_lineView setBackgroundColor:[SNAppDelegate snLineColor]];
		[self addSubview:_lineView];
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)setTwitterUserVO:(SNTwitterUserVO *)twitterUserVO {
	_twitterUserVO = twitterUserVO;
	
	SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(25.0, 18.0) imageURL:twitterUserVO.avatarURL];
	[self addSubview:avatarImgView];
	
	_handleLabel.text = [NSString stringWithFormat:@"@%@", _twitterUserVO.handle];
}

@end
